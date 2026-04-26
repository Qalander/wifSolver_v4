#ifndef STEP_STRIDE_H
#define STEP_STRIDE_H

#include <stdio.h>
#include "lib/Int.h"

inline bool applyStepStrideConfig(int step, int step2, Int &STRIDE, Int &STRIDE2, Int &down)
{
    if (step < 9)
    {
        printf("\n  ERROR     : Mistake! Rotate checksum in development! Minimum character -n 9  (max -n 51)\n\n");
        return false;
    }

    if (step == 9)
    {
        STRIDE.SetBase16((char *)"7479027ea100");
    }
    if (step == 10)
    {
        STRIDE.SetBase16((char *)"1a636a90b07a00");
    }
    if (step == 11)
    {
        STRIDE.SetBase16((char *)"5fa8624c7fba400");
    }
    if (step == 12)
    {
        STRIDE.SetBase16((char *)"15ac264554f032800");
    }
    if (step == 13)
    {
        STRIDE.SetBase16((char *)"4e900abb53e6b71000");
    }
    if (step == 14)
    {
        STRIDE.SetBase16((char *)"11cca26e71024579a000");
    }
    if (step == 15)
    {
        STRIDE.SetBase16((char *)"4085ccd059a83bd8e4000");
    }
    if (step == 16)
    {
        STRIDE.SetBase16((char *)"e9e506734501d8f23a8000");
    }
    if (step == 17)
    {
        STRIDE.SetBase16((char *)"34fde3761da26b26e1410000");
    }
    if (step == 18)
    {
        STRIDE.SetBase16((char *)"c018588c2b6cc46cf08ba0000");
    }
    if (step == 19)
    {
        STRIDE.SetBase16((char *)"2b85840fc1d6a480ae7fa240000");
    }
    if (step == 20)
    {
        STRIDE.SetBase16((char *)"9dc3feb91eaa1452788eac280000");
    }
    if (step == 21)
    {
        STRIDE.SetBase16((char *)"23be67b5f0f2889aaf505301100000");
    }
    if (step == 22)
    {
        STRIDE.SetBase16((char *)"819237f3896f2f30bb832ce3da00000");
    }
    if (step == 23)
    {
        STRIDE.SetBase16((char *)"1d5b20ad2d2330b10a7bb82b9f6400000");
    }
    if (step == 24)
    {
        STRIDE.SetBase16((char *)"6a6a5673c39f9081c6007b9e21ca800000");
    }
    if (step == 25)
    {
        STRIDE.SetBase16((char *)"181c17963a5226bd66dc1c01d3a7e1000000");
    }
    if (step == 26)
    {
        STRIDE.SetBase16((char *)"5765d5809369cc6e94dde5869f408fa000000");
    }
    if (step == 27)
    {
        STRIDE.SetBase16((char *)"13cd125f2165f8510dba46008014a08a4000000");
    }
    if (step == 28)
    {
        STRIDE.SetBase16((char *)"47c76298d911a425d1c33dc1d04ac5f528000000");
    }
    if (step == 29)
    {
        STRIDE.SetBase16((char *)"10432c56a12dff3091863bfde930f0d98b10000000");
    }
    if (step == 30)
    {
        STRIDE.SetBase16((char *)"3af380ba0846bd100f8699786d516914981a0000000");
    }
    if (step == 31)
    {
        STRIDE.SetBase16((char *)"d5b2b2a25e006d5a3847ec548c471ceaa75e40000000");
    }
    if (step == 32)
    {
        STRIDE.SetBase16((char *)"306a7c78c94c18c670c04b8b27c81c8d29eb5a80000000");
    }
    if (step == 33)
    {
        STRIDE.SetBase16((char *)"af820335d9b3d9cf58b911d87035677fb7f528100000000");
    }
    if (step == 34)
    {
        STRIDE.SetBase16((char *)"27c374ba3352bf58fa19ee0b096c1972efad8b13a00000000");
    }
    if (step == 35)
    {
        STRIDE.SetBase16((char *)"90248722fa0bf5a28a9dfee80227dc40a4d518272400000000");
    }
    if (step == 36)
    {
        STRIDE.SetBase16((char *)"20a8469deca6b5a6d367cbc0907d07e6a5584778de2800000000");
    }
    if (step == 37)
    {
        STRIDE.SetBase16((char *)"7661fffc79dc527cbe58429a0bc53ca4176003162551000000000");
    }
    if (step == 38)
    {
        STRIDE.SetBase16((char *)"1ad233ff339beab0431fff16e6aaafbd2d4bc0b304745a000000000");
    }
    if (step == 39)
    {
        STRIDE.SetBase16((char *)"6139fc7d1b1532bef353fcb3042abd0dc4329a88f025c64000000000");
    }
    if (step == 40)
    {
        STRIDE.SetBase16((char *)"160723345822cd7f432107408ef1aed51e73770306688eea8000000000");
    }
    if (step == 41)
    {
        STRIDE.SetBase16((char *)"4fd9df9dbf7e28ed5357ba4a062c19c48e628f6af73b061210000000000");
    }
    if (step == 42)
    {
        STRIDE.SetBase16((char *)"12175ca9bd629545c4e1e034c565fdd68842547e3c035f6017a0000000000");
    }
    if (step == 43)
    {
        STRIDE.SetBase16((char *)"4194afe74e855d1ce9b2ccbf4b91b829adf07249998c39bc55a40000000000");
    }
    if (step == 44)
    {
        STRIDE.SetBase16((char *)"edbafda67ca37188cf28263571f03b9716879e4acc9c514ab67280000000000");
    }
    if (step == 45)
    {
        STRIDE.SetBase16((char *)"35dc5d77b83d07b8feef18a81bd06d803b1ab9dcf25b6a6aed55f100000000000");
    }
    if (step == 46)
    {
        STRIDE.SetBase16((char *)"c33ed2d1fbdd3bfe9c22b96164d38cf0d640e1c0ee8b61c39c5789a00000000000");
    }
    if (step == 47)
    {
        STRIDE.SetBase16((char *)"2c3c3bc393101f97af5fde0010d7edee908ab325b60b9426516bd52e400000000000");
    }
    if (step == 48)
    {
        STRIDE.SetBase16((char *)"a05a58a4f51a7285dbbb84c03d0ebe80cbf6c968b3e9f90ae726e4c7a800000000000");
    }
    if (step == 49)
    {
        STRIDE.SetBase16((char *)"245478155f87fdf253c87c138dd557292e35e9a1b8c3026c785ecfd53c1000000000000");
    }
    if (step == 50)
    {
        STRIDE.SetBase16((char *)"83b2334d7a4cf88e6fb6c1c6e2255bf547836eea3dc2e8c93457b164f9ba000000000000");
    }
    if (step == 51)
    {
        STRIDE.SetBase16((char *)"1dd65f9f8db57050454f67e70f3c76d59233c72111fe28bd95dbde30e09424000000000000");
    }
    if (step < 9)
    {
        printf("\n  ERROR     : Mistake! Rotate checksum in development! Minimum character -n 9  (max -n 51)\n\n");
        return false;
    }

    if (step2 == 9)
    {
        STRIDE2.SetBase16((char *)"7479027ea100");
    }
    if (step2 == 10)
    {
        STRIDE2.SetBase16((char *)"1a636a90b07a00");
    }
    if (step2 == 11)
    {
        STRIDE2.SetBase16((char *)"5fa8624c7fba400");
    }
    if (step2 == 12)
    {
        STRIDE2.SetBase16((char *)"15ac264554f032800");
    }
    if (step2 == 13)
    {
        STRIDE2.SetBase16((char *)"4e900abb53e6b71000");
    }
    if (step2 == 14)
    {
        STRIDE2.SetBase16((char *)"11cca26e71024579a000");
    }
    if (step2 == 15)
    {
        STRIDE2.SetBase16((char *)"4085ccd059a83bd8e4000");
    }
    if (step2 == 16)
    {
        STRIDE2.SetBase16((char *)"e9e506734501d8f23a8000");
    }
    if (step2 == 17)
    {
        STRIDE2.SetBase16((char *)"34fde3761da26b26e1410000");
    }
    if (step2 == 18)
    {
        STRIDE2.SetBase16((char *)"c018588c2b6cc46cf08ba0000");
    }
    if (step2 == 19)
    {
        STRIDE2.SetBase16((char *)"2b85840fc1d6a480ae7fa240000");
    }
    if (step2 == 20)
    {
        STRIDE2.SetBase16((char *)"9dc3feb91eaa1452788eac280000");
    }
    if (step2 == 21)
    {
        STRIDE2.SetBase16((char *)"23be67b5f0f2889aaf505301100000");
    }
    if (step2 == 22)
    {
        STRIDE2.SetBase16((char *)"819237f3896f2f30bb832ce3da00000");
    }
    if (step2 == 23)
    {
        STRIDE2.SetBase16((char *)"1d5b20ad2d2330b10a7bb82b9f6400000");
    }
    if (step2 == 24)
    {
        STRIDE2.SetBase16((char *)"6a6a5673c39f9081c6007b9e21ca800000");
    }
    if (step2 == 25)
    {
        STRIDE2.SetBase16((char *)"181c17963a5226bd66dc1c01d3a7e1000000");
    }
    if (step2 == 26)
    {
        STRIDE2.SetBase16((char *)"5765d5809369cc6e94dde5869f408fa000000");
    }
    if (step2 == 27)
    {
        STRIDE2.SetBase16((char *)"13cd125f2165f8510dba46008014a08a4000000");
    }
    if (step2 == 28)
    {
        STRIDE2.SetBase16((char *)"47c76298d911a425d1c33dc1d04ac5f528000000");
    }
    if (step2 == 29)
    {
        STRIDE2.SetBase16((char *)"10432c56a12dff3091863bfde930f0d98b10000000");
    }
    if (step2 == 30)
    {
        STRIDE2.SetBase16((char *)"3af380ba0846bd100f8699786d516914981a0000000");
    }
    if (step2 == 31)
    {
        STRIDE2.SetBase16((char *)"d5b2b2a25e006d5a3847ec548c471ceaa75e40000000");
    }
    if (step2 == 32)
    {
        STRIDE2.SetBase16((char *)"306a7c78c94c18c670c04b8b27c81c8d29eb5a80000000");
    }
    if (step2 == 33)
    {
        STRIDE2.SetBase16((char *)"af820335d9b3d9cf58b911d87035677fb7f528100000000");
    }
    if (step2 == 34)
    {
        STRIDE2.SetBase16((char *)"27c374ba3352bf58fa19ee0b096c1972efad8b13a00000000");
    }
    if (step2 == 35)
    {
        STRIDE2.SetBase16((char *)"90248722fa0bf5a28a9dfee80227dc40a4d518272400000000");
    }
    if (step2 == 36)
    {
        STRIDE2.SetBase16((char *)"20a8469deca6b5a6d367cbc0907d07e6a5584778de2800000000");
    }
    if (step2 == 37)
    {
        STRIDE2.SetBase16((char *)"7661fffc79dc527cbe58429a0bc53ca4176003162551000000000");
    }
    if (step2 == 38)
    {
        STRIDE2.SetBase16((char *)"1ad233ff339beab0431fff16e6aaafbd2d4bc0b304745a000000000");
    }
    if (step2 == 39)
    {
        STRIDE2.SetBase16((char *)"6139fc7d1b1532bef353fcb3042abd0dc4329a88f025c64000000000");
    }
    if (step2 == 40)
    {
        STRIDE2.SetBase16((char *)"160723345822cd7f432107408ef1aed51e73770306688eea8000000000");
    }
    if (step2 == 41)
    {
        STRIDE2.SetBase16((char *)"4fd9df9dbf7e28ed5357ba4a062c19c48e628f6af73b061210000000000");
    }
    if (step2 == 42)
    {
        STRIDE2.SetBase16((char *)"12175ca9bd629545c4e1e034c565fdd68842547e3c035f6017a0000000000");
    }
    if (step2 == 43)
    {
        STRIDE2.SetBase16((char *)"4194afe74e855d1ce9b2ccbf4b91b829adf07249998c39bc55a40000000000");
    }
    if (step2 == 44)
    {
        STRIDE2.SetBase16((char *)"edbafda67ca37188cf28263571f03b9716879e4acc9c514ab67280000000000");
    }
    if (step2 == 45)
    {
        STRIDE.SetBase16((char *)"35dc5d77b83d07b8feef18a81bd06d803b1ab9dcf25b6a6aed55f100000000000");
    }
    if (step2 == 46)
    {
        STRIDE2.SetBase16((char *)"c33ed2d1fbdd3bfe9c22b96164d38cf0d640e1c0ee8b61c39c5789a00000000000");
    }
    if (step2 == 47)
    {
        STRIDE2.SetBase16((char *)"2c3c3bc393101f97af5fde0010d7edee908ab325b60b9426516bd52e400000000000");
    }
    if (step2 == 48)
    {
        STRIDE.SetBase16((char *)"a05a58a4f51a7285dbbb84c03d0ebe80cbf6c968b3e9f90ae726e4c7a800000000000");
    }
    if (step2 == 49)
    {
        STRIDE2.SetBase16((char *)"245478155f87fdf253c87c138dd557292e35e9a1b8c3026c785ecfd53c1000000000000");
    }
    if (step2 == 50)
    {
        STRIDE2.SetBase16((char *)"83b2334d7a4cf88e6fb6c1c6e2255bf547836eea3dc2e8c93457b164f9ba000000000000");
    }
    if (step2 == 51)
    {
        STRIDE2.SetBase16((char *)"1dd65f9f8db57050454f67e70f3c76d59233c72111fe28bd95dbde30e09424000000000000");
    }

    int step3 = step - 1;
    if (step3 == 9)
    {
        down.SetBase16((char *)"7479027ea100");
    }
    if (step3 == 10)
    {
        down.SetBase16((char *)"1a636a90b07a00");
    }
    if (step3 == 11)
    {
        down.SetBase16((char *)"5fa8624c7fba400");
    }
    if (step3 == 12)
    {
        down.SetBase16((char *)"15ac264554f032800");
    }
    if (step3 == 13)
    {
        down.SetBase16((char *)"4e900abb53e6b71000");
    }
    if (step3 == 14)
    {
        down.SetBase16((char *)"11cca26e71024579a000");
    }
    if (step3 == 15)
    {
        down.SetBase16((char *)"4085ccd059a83bd8e4000");
    }
    if (step2 == 16)
    {
        down.SetBase16((char *)"e9e506734501d8f23a8000");
    }
    if (step3 == 17)
    {
        down.SetBase16((char *)"34fde3761da26b26e1410000");
    }
    if (step3 == 18)
    {
        down.SetBase16((char *)"c018588c2b6cc46cf08ba0000");
    }
    if (step3 == 19)
    {
        down.SetBase16((char *)"2b85840fc1d6a480ae7fa240000");
    }
    if (step3 == 20)
    {
        down.SetBase16((char *)"9dc3feb91eaa1452788eac280000");
    }
    if (step3 == 21)
    {
        down.SetBase16((char *)"23be67b5f0f2889aaf505301100000");
    }
    if (step3 == 22)
    {
        down.SetBase16((char *)"819237f3896f2f30bb832ce3da00000");
    }
    if (step3 == 23)
    {
        down.SetBase16((char *)"1d5b20ad2d2330b10a7bb82b9f6400000");
    }
    if (step3 == 24)
    {
        down.SetBase16((char *)"6a6a5673c39f9081c6007b9e21ca800000");
    }
    if (step3 == 25)
    {
        down.SetBase16((char *)"181c17963a5226bd66dc1c01d3a7e1000000");
    }
    if (step3 == 26)
    {
        down.SetBase16((char *)"5765d5809369cc6e94dde5869f408fa000000");
    }
    if (step3 == 27)
    {
        down.SetBase16((char *)"13cd125f2165f8510dba46008014a08a4000000");
    }
    if (step3 == 28)
    {
        down.SetBase16((char *)"47c76298d911a425d1c33dc1d04ac5f528000000");
    }
    if (step3 == 29)
    {
        down.SetBase16((char *)"10432c56a12dff3091863bfde930f0d98b10000000");
    }
    if (step3 == 30)
    {
        down.SetBase16((char *)"3af380ba0846bd100f8699786d516914981a0000000");
    }
    if (step3 == 31)
    {
        down.SetBase16((char *)"d5b2b2a25e006d5a3847ec548c471ceaa75e40000000");
    }
    if (step3 == 32)
    {
        down.SetBase16((char *)"306a7c78c94c18c670c04b8b27c81c8d29eb5a80000000");
    }
    if (step3 == 33)
    {
        down.SetBase16((char *)"af820335d9b3d9cf58b911d87035677fb7f528100000000");
    }
    if (step3 == 34)
    {
        down.SetBase16((char *)"27c374ba3352bf58fa19ee0b096c1972efad8b13a00000000");
    }
    if (step3 == 35)
    {
        STRIDE2.SetBase16((char *)"90248722fa0bf5a28a9dfee80227dc40a4d518272400000000");
    }
    if (step3 == 36)
    {
        down.SetBase16((char *)"20a8469deca6b5a6d367cbc0907d07e6a5584778de2800000000");
    }
    if (step3 == 37)
    {
        down.SetBase16((char *)"7661fffc79dc527cbe58429a0bc53ca4176003162551000000000");
    }
    if (step3 == 38)
    {
        down.SetBase16((char *)"1ad233ff339beab0431fff16e6aaafbd2d4bc0b304745a000000000");
    }
    if (step3 == 39)
    {
        down.SetBase16((char *)"6139fc7d1b1532bef353fcb3042abd0dc4329a88f025c64000000000");
    }
    if (step3 == 40)
    {
        down.SetBase16((char *)"160723345822cd7f432107408ef1aed51e73770306688eea8000000000");
    }
    if (step3 == 41)
    {
        down.SetBase16((char *)"4fd9df9dbf7e28ed5357ba4a062c19c48e628f6af73b061210000000000");
    }
    if (step3 == 42)
    {
        down.SetBase16((char *)"12175ca9bd629545c4e1e034c565fdd68842547e3c035f6017a0000000000");
    }
    if (step3 == 43)
    {
        down.SetBase16((char *)"4194afe74e855d1ce9b2ccbf4b91b829adf07249998c39bc55a40000000000");
    }
    if (step3 == 44)
    {
        down.SetBase16((char *)"edbafda67ca37188cf28263571f03b9716879e4acc9c514ab67280000000000");
    }
    if (step3 == 45)
    {
        down.SetBase16((char *)"35dc5d77b83d07b8feef18a81bd06d803b1ab9dcf25b6a6aed55f100000000000");
    }
    if (step3 == 46)
    {
        down.SetBase16((char *)"c33ed2d1fbdd3bfe9c22b96164d38cf0d640e1c0ee8b61c39c5789a00000000000");
    }
    if (step3 == 47)
    {
        down.SetBase16((char *)"2c3c3bc393101f97af5fde0010d7edee908ab325b60b9426516bd52e400000000000");
    }
    if (step3 == 48)
    {
        down.SetBase16((char *)"a05a58a4f51a7285dbbb84c03d0ebe80cbf6c968b3e9f90ae726e4c7a800000000000");
    }
    if (step3 == 49)
    {
        down.SetBase16((char *)"245478155f87fdf253c87c138dd557292e35e9a1b8c3026c785ecfd53c1000000000000");
    }
    if (step3 == 50)
    {
        down.SetBase16((char *)"83b2334d7a4cf88e6fb6c1c6e2255bf547836eea3dc2e8c93457b164f9ba000000000000");
    }
    if (step3 == 51)
    {
        down.SetBase16((char *)"1dd65f9f8db57050454f67e70f3c76d59233c72111fe28bd95dbde30e09424000000000000");
    }

    return true;
}

#endif