// Author: Mohamed Sohail <sohail@grassecon.org>
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {PriceIndexQuoter} from "../src/PriceIndexQuoter.sol";

/*
Everything is relative to 10 KES.
Therefore:

1 SRF = 1
1 MBAO = 2 (1 MBAO = 20 KES)
1 USD = 14.5 (1 USD = 145 KES)
1 MUU = 1
1 TZS = 0.005 (1 KES = 20 TZS)
1 ZAR = 0.755 (1 ZAR = 7.55 KES)
1 USDC = 14.66 ((1 USDC = 146.6 KES) (18 decimals)

These relative prices need to be represented in fixed point numbers.
We can therefore multiply each by 10 ** 4:

1 SRF = 10_000
1 MBAO = 20_000
1 USD = 145_000
1 MUU = 10_000
1 TZS = 50
i ZAR = 7_550
1 USDC = 146_600

N.B:

* The default rate is always 10_000 because we assume it is a standard CAV.
* Unless otherwise stated, all CAV above have a decimal precision of 6

*/
contract PriceIndexQuoterTest is Test {
    PriceIndexQuoter public quoter;

    // Default values
    uint256 defaultInExchangeRate = 10_000;
    uint256 defaultOutExchangeRate = 10_000;

    // ratesSet
    uint256 SRFRate = 10_000;
    uint256 MBAORate = 20_000;
    uint256 USDRate = 145_000;
    uint256 MUURate = 10_000;
    uint256 TZSRate = 50;
    uint256 ZARRate = 7_550;
    uint256 USDCRate = 146_600;

    function setUp() public {
        quoter = new PriceIndexQuoter();

    }

    function test_determineOutput_similarDecimals_noRatesSet() public {
        /*      
        Rates not set  
        1 ABC in
        1 XYZ out
        */
        uint256 input = 1_000_000;
        uint256 expectedOut = 1_000_000;
        
        uint256 x = quoter.determineOutput(input, defaultInExchangeRate, defaultOutExchangeRate);

        assertEq(x, expectedOut);
    }

    function test_determineOutput_similarDecimals_1() public {
        /*      
        1 MBAO in
        2 SRF out
        */        
        uint256 input = 1_000_000;
        uint256 expectedOut = 2_000_000;

        uint256 inRate = MBAORate;
        uint256 outRate = SRFRate;
        
        uint256 x = quoter.determineOutput(input, inRate, outRate);

        assertEq(x, expectedOut);
    }

    function test_determineOutput_similarDecimals_2() public {
        /*      
        1 SRF in
        0.5 MBAO out
        */               
        uint256 input = 1_000_000;
        uint256 expectedOut = 500_000;

        uint256 inRate = SRFRate;
        uint256 outRate = MBAORate;
        
        uint256 x = quoter.determineOutput(input, inRate, outRate);

        assertEq(x, expectedOut);
    }

    function test_determineOutput_similarDecimals_3() public {
        /*      
        1000 SRF in
        ~ 68 USD out
        */          
        uint256 input = 1_000_000_000;
        uint256 expectedOut = 68_965_517;

        uint256 inRate = SRFRate;
        uint256 outRate = USDRate;
        
        uint256 x = quoter.determineOutput(input, inRate, outRate);

        assertEq(x, expectedOut);
    }


    function test_determineOutput_similarDecimals_4() public {
        /*      
        1000 SRF in
        ~ 200,000 TZS out
        */  
        uint256 input = 1_000_000_000;
        uint256 expectedOut = 200_000_000_000;

        uint256 inRate = SRFRate;
        uint256 outRate = TZSRate;
        
        uint256 x = quoter.determineOutput(input, inRate, outRate);

        assertEq(x, expectedOut);
    }


    function test_determineOutput_similarDecimals_5() public {
        /*      
        1000 ZAR in
        ~ 52 USD out
        */  
        uint256 input = 1_000_000_000;
        uint256 expectedOut = 52_068_965;

        uint256 inRate = ZARRate;
        uint256 outRate = USDRate;
        
        uint256 x = quoter.determineOutput(input, inRate, outRate);

        assertEq(x, expectedOut);
    }

    function test_determineOutput_similarDecimals_6() public {
        /*      
        100 TZS in
        ~ 0.034 USD out
        */  
        uint256 input = 100_000_000;
        uint256 expectedOut = 34_482;

        uint256 inRate = TZSRate;
        uint256 outRate = USDRate;
        
        uint256 x = quoter.determineOutput(input, inRate, outRate);

        assertEq(x, expectedOut);
    }

    function test_determineOutput_USDCIn_SRFOut() public {
        /*      
        100 USDC in
        1466 SRF out
        */  
        uint din = 18;
        uint dout = 6;

        uint256 input = 100 * 10**18;
        uint256 expectedOut = 1_466_000_000;        

        uint256 d = din > dout ? 10 ** ((din - dout)) : 10 ** ((dout - din));

        uint256 inRate = USDCRate;
        uint256 outRate = SRFRate;
        
        uint256 x = quoter.determineOutput(input/d, inRate, outRate);

        assertEq(x, expectedOut);
    }

    function test_determineOutput_SRFIn_USDCOut() public {
        /*      
        100 SRF in
        ~ 6 USDC out
        */  
        uint din = 6;
        uint dout = 18;

        uint256 input = 100_000_000;
        uint256 expectedOut = 6_821_282_401_091_405_184;   

        uint256 d = din > dout ? 10 ** ((din - dout)) : 10 ** ((dout - din));

        uint256 inRate = SRFRate;
        uint256 outRate = USDCRate;
        
        uint256 x = quoter.determineOutput(input*d, inRate, outRate);

        assertEq(x, expectedOut);
    }      
}
