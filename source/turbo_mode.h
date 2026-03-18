#pragma once

#include <algorithm>
#include <array>
#include <cctype>
#include <cstdio>
#include <memory>
#include <regex>
#include <string>
#include <vector>

#include "lib/Int.h"
#include "lib/util.h"

namespace TurboRotation
{
struct Context
{
    int turboLevel;
    int &zapusk;
    int &zcount;
    std::string &zamena;
    std::string &zamena2;
    std::string &zamena3;
    std::string &security;
    std::string &kstr99;
    std::vector<char> &alreadyPrinted;
    Int &rangeStart;
    Int &down;
    const std::string &wifStart;
    int step;
};

namespace detail
{
inline std::vector<std::pair<std::regex, std::string>> &rotationRules()
{
    static std::vector<std::pair<std::regex, std::string>> rules = [] {
        std::vector<std::pair<std::regex, std::string>> out;
        out.reserve(25 * 8 + 1);

        auto emit = [&](char current, char next) {
            for (unsigned int mask = 0; mask < 8; ++mask)
            {
                std::array<char, 3> pattern{current, current, current};
                std::array<char, 3> replace{current, current, next};

                for (size_t i = 0; i < pattern.size(); ++i)
                {
                    const bool lower = (mask >> i) & 1U;
                    pattern[i] = lower ? static_cast<char>(std::tolower(pattern[i])) : static_cast<char>(std::toupper(pattern[i]));
                    replace[i] = lower ? static_cast<char>(std::tolower(replace[i])) : static_cast<char>(std::toupper(replace[i]));
                }

                out.emplace_back(std::regex(std::string(pattern.data(), pattern.size())), std::string(replace.data(), replace.size()));
            }
        };

        for (char c = 'A'; c < 'Z'; ++c)
        {
            emit(c, static_cast<char>(c + 1));
        }

        out.emplace_back(std::regex("111"), "112");
        out.emplace_back(std::regex("222"), "223");
        out.emplace_back(std::regex("333"), "334");
        out.emplace_back(std::regex("444"), "445");
        out.emplace_back(std::regex("555"), "556");
        out.emplace_back(std::regex("666"), "667");
        out.emplace_back(std::regex("777"), "778");
        out.emplace_back(std::regex("888"), "889");
        out.emplace_back(std::regex("999"), "99A");


        return out;
    }();
    return rules;
}

inline std::string rotateOnce(std::string value)
{
    for (const auto &rule : rotationRules())
    {
        value = std::regex_replace(value, rule.first, rule.second);
    }
    return value;
}

} // namespace detail

inline void spin(Context &ctx, const std::string &wifValue)
{
    if (ctx.turboLevel <= 0)
    {
        return;
    }

    ctx.zapusk += 1;

    if (ctx.zapusk > 27)
    {
        int asciiArray[256] = {0};
        for (unsigned char c : wifValue)
        {
            asciiArray[c]++;
        }

        for (unsigned char c : wifValue)
        {
            const bool tooCommon = asciiArray[c] > 2;
            const bool unseen = std::find(ctx.alreadyPrinted.begin(), ctx.alreadyPrinted.end(), static_cast<char>(c)) == ctx.alreadyPrinted.end();

            if (tooCommon && unseen)
            {
                const std::string rotated = detail::rotateOnce(wifValue);

                if (rotated != wifValue)
                {
                    ctx.zamena = wifValue;
                    ctx.zamena2 = rotated;

                    const char *base58 = ctx.zamena2.c_str();
                    size_t base58Length = ctx.zamena2.size();
                    size_t keybuflen = base58Length == 52 ? 38 : 37;
                    std::unique_ptr<unsigned char[]> keybuf(new unsigned char[keybuflen]);
                    b58decode(keybuf.get(), &keybuflen, base58, base58Length);

                    std::string nos2;
                    nos2.reserve(keybuflen * 2);
                    for (size_t i = 0; i < keybuflen; i++)
                    {
                        char s[3];
                        snprintf(s, sizeof(s), "%.2x", keybuf[i]);
                        nos2.append(s);
                    }
                    ctx.rangeStart.SetBase16((char*)nos2.c_str());
                }
                break;
            }
        }
        ctx.zapusk = 0;
    }

    if (ctx.zamena3 != ctx.zamena2)
    {
        ctx.zamena3 = ctx.zamena2;
        ctx.zcount += 1;

        if (ctx.zcount > 1)
        {
            const int konec = static_cast<int>(ctx.zamena2.length());
            ctx.kstr99 = ctx.zamena2.substr(konec - ctx.step + 1, 1);

            const int konec555 = static_cast<int>(ctx.wifStart.length());
            ctx.security = ctx.wifStart.substr(konec555 - ctx.step + 1, 1);

            if (ctx.kstr99 != ctx.security)
            {
                printf("  Letter return   : %s -> %s \n", ctx.security.c_str(), ctx.kstr99.c_str());
                ctx.rangeStart.Sub(&ctx.down);
            }
        }
    }
}

} // namespace TurboRotation
