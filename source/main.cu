#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <vector>
#include <regex>
#include <string>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>
#include <iostream>
#include <chrono>
#include "Timer.h"
#include "lib/Int.h"
#include "lib/Math.cuh"
#include "lib/util.h"
#include "Worker.cuh"
#include "step_stride.h"
#include <sstream>
#include "lib/SECP256k1.h"
#include "turbo_mode.h"

using namespace std;

void processCandidate(Int &toTest);
bool readArgs(int argc, char **argv);
void showHelp();
bool checkDevice();
void listDevices();
void printConfig();
void printSpeed(double speed);
void saveStatus();

cudaError_t processCuda();
cudaError_t processCudaUnified();

bool unifiedMemory = true;

int DEVICE_NR = 0;
unsigned int BLOCK_THREADS = 0;
unsigned int BLOCK_NUMBER = 0;
unsigned int THREAD_STEPS = 5000;
size_t wifLen = 53;
int dataLen = 37;
int zapusk;
int turbo;
bool COMPRESSED = true;
Int STRIDE, STRIDE2, RANGE_START, RANGE_END, RANGE_START_TOTAL, RANGE_TOTAL;
double RANGE_TOTAL_DOUBLE;
Int loopStride;
Int counter;
string TARGET_ADDRESS = "";
string WIF = "";
string WIF999 = "";
string WIFSTART = "";
string WIFEND = "";
string part1 = "";
string part2 = "";
string verh;
string num_str;
string nitro;
string zamena = "TURBO MODE: WIF KEY BEFORE";
string zamena2 = "WIF KEY AFTER";
string zamena3;
string security;
string kstr99;
int zcount;
Int start1;
Int shagi;
Int end1;
Int CHECKSUM;
Int down;
bool IS_CHECKSUM = false;

bool DECODE = true;
string WIF_TO_DECODE;
string wifout = "";
bool RESULT = false;
char timeStr[256];
char timeStr2[256];
std::string formatThousands(uint64_t x);
uint64_t outputSize;
uint64_t speed3;
double t0;
double t1;
double t_tmp;
string fileResultPartial = "FOUND_partial.txt";
string fileResult = "FOUND.txt";
string Continue777 = "Continue.txt";
int fileStatusInterval = 60;
int step;
int step2;
int kusok;
string fileStatusRestore;
bool isRestore = false;
char *toTimeStr(int sec, char *timeStr);
bool showDevices = false;
bool p2sh = false;
vector<char> alreadyprintedcharacters;

// Prefix mode variables
bool usePrefixMode = false;
string prefixesFile = "./prefixes.txt";
vector<string> prefixesList;
int currentPrefixIndex = 0;
string wifTemplate = "";
string prefixPlaceholder = "YYYYY";

Secp256K1 *secp;

// Check if prefix contains invalid Base58 characters (0, O, I, l)
bool hasInvalidBase58Chars(const string &prefix)
{
    for (char c : prefix)
    {
        if (c == '0' || c == 'O' || c == 'I' || c == 'l')
        {
            return true;
        }
    }
    return false;
}

// Load prefixes from file
bool loadPrefixesFromFile(const string &filename)
{
    FILE *file = fopen(filename.c_str(), "r");
    if (!file)
    {
        fprintf(stderr, "  ERROR: Cannot open prefixes file: %s\n\n", filename.c_str());
        return false;
    }

    char line[256];
    int skipped = 0;
    while (fgets(line, sizeof(line), file))
    {
        // Remove newline characters
        size_t len = strlen(line);
        while (len > 0 && (line[len - 1] == '\n' || line[len - 1] == '\r'))
        {
            line[--len] = '\0';
        }

        // Skip empty lines and invalid prefixes
        if (len > 0)
        {
            string prefix(line);
            if (hasInvalidBase58Chars(prefix))
            {
                fprintf(stderr, "  WARNING: Skipping prefix '%s' (contains invalid Base58 characters: 0, O, I, l)\n", prefix.c_str());
                skipped++;
            }
            else
            {
                prefixesList.push_back(prefix);
            }
        }
    }
    fclose(file);

    if (prefixesList.empty())
    {
        fprintf(stderr, "  ERROR: Prefixes file is empty or all prefixes were invalid: %s\n\n", filename.c_str());
        return false;
    }

    printf("  Loaded %zu prefixes from file: %s", prefixesList.size(), filename.c_str());
    if (skipped > 0)
    {
        printf(" (skipped %d invalid prefixes)", skipped);
    }
    printf("\n");
    return true;
}

// Get current prefix
string getCurrentPrefix()
{
    if (currentPrefixIndex >= prefixesList.size())
    {
        return "";
    }
    return prefixesList[currentPrefixIndex];
}

// Substitute prefix into WIF template
string substitutePrefix(const string &prefix)
{
    string result = wifTemplate;
    size_t pos = result.find(prefixPlaceholder);
    if (pos != string::npos)
    {
        result.replace(pos, prefixPlaceholder.length(), prefix);
    }
    return result;
}

// Check if there are more prefixes to process
bool hasMorePrefixes()
{
    return currentPrefixIndex < prefixesList.size();
}

// Advance to next prefix
void nextPrefix()
{
    currentPrefixIndex++;
}

// Process WIF and extract WIFSTART (reusable from readArgs logic)
bool processPrefixWIF()
{
    if (WIF.length() < 51 || WIF.length() > 52)
    {
        fprintf(stderr, "  ERROR WIF: Invalid WIF length %zu\n\n", WIF.length());
        return false;
    }

    // Reset and extract WIFSTART
    alreadyprintedcharacters.clear();
    WIFSTART = "";

    string wifs = WIF;
    int asciiArray[256];
    char ch;
    int charconv;
    for (int i = 0; i < 256; i++)
        asciiArray[i] = 0;
    for (unsigned int i = 0; i < wifs.length(); i++)
    {
        ch = wifs[i];
        charconv = static_cast<int>(ch);
        asciiArray[charconv]++;
    }

    char alreadyprinted = '\0'; // Local variable, not static
    for (unsigned int i = 0; i < wifs.length(); i++)
    {
        ch = wifs[i];

        if ((asciiArray[ch] > 2) && (ch != alreadyprinted) && (find(alreadyprintedcharacters.begin(), alreadyprintedcharacters.end(), ch) == alreadyprintedcharacters.end()))
        {
            alreadyprintedcharacters.push_back(ch);
            alreadyprinted = ch;

            string proverka = wifs;

            string proverka1 = regex_replace(proverka, regex("XXXXXXXXXXXXXXX"), "111111111111111");
            string proverka2 = regex_replace(proverka1, regex("XXXXXXXXXXXXXX"), "11111111111111");
            string proverka3 = regex_replace(proverka2, regex("XXXXXXXXXXXXX"), "1111111111111");
            string proverka4 = regex_replace(proverka3, regex("XXXXXXXXXXXX"), "111111111111");
            string proverka5 = regex_replace(proverka4, regex("XXXXXXXXXXX"), "11111111111");
            string proverka6 = regex_replace(proverka5, regex("XXXXXXXXXX"), "1111111111");
            string proverka7 = regex_replace(proverka6, regex("XXXXXXXXX"), "111111111");
            string proverka8 = regex_replace(proverka7, regex("XXXXXXXX"), "11111111");
            string proverka9 = regex_replace(proverka8, regex("XXXXXXX"), "1111111");
            string proverka10 = regex_replace(proverka9, regex("XXXXXX"), "111111");
            string proverka11 = regex_replace(proverka10, regex("XXXXX"), "11111");
            string proverka12 = regex_replace(proverka11, regex("XXXX"), "1111");
            WIFSTART = proverka12;
        }
    }

    if (WIFSTART.empty())
    {
        fprintf(stderr, "  ERROR: Could not extract WIFSTART from WIF\n\n");
        return false;
    }

    // Extract WIFEND (same logic but with 'z' instead of '1')
    alreadyprintedcharacters.clear();
    WIFEND = "";
    alreadyprinted = '\0';

    for (unsigned int i = 0; i < wifs.length(); i++)
    {
        ch = wifs[i];

        if ((asciiArray[ch] > 2) && (ch != alreadyprinted) && (find(alreadyprintedcharacters.begin(), alreadyprintedcharacters.end(), ch) == alreadyprintedcharacters.end()))
        {
            alreadyprintedcharacters.push_back(ch);
            alreadyprinted = ch;

            string proverka = wifs;

            string proverka1 = regex_replace(proverka, regex("XXXXXXXXXXXXXXX"), "zzzzzzzzzzzzzzz");
            string proverka2 = regex_replace(proverka1, regex("XXXXXXXXXXXXXX"), "zzzzzzzzzzzzzz");
            string proverka3 = regex_replace(proverka2, regex("XXXXXXXXXXXXX"), "zzzzzzzzzzzzz");
            string proverka4 = regex_replace(proverka3, regex("XXXXXXXXXXXX"), "zzzzzzzzzzzz");
            string proverka5 = regex_replace(proverka4, regex("XXXXXXXXXXX"), "zzzzzzzzzzz");
            string proverka6 = regex_replace(proverka5, regex("XXXXXXXXXX"), "zzzzzzzzzz");
            string proverka7 = regex_replace(proverka6, regex("XXXXXXXXX"), "zzzzzzzzz");
            string proverka8 = regex_replace(proverka7, regex("XXXXXXXX"), "zzzzzzzz");
            string proverka9 = regex_replace(proverka8, regex("XXXXXXX"), "zzzzzzz");
            string proverka10 = regex_replace(proverka9, regex("XXXXXX"), "zzzzzz");
            string proverka11 = regex_replace(proverka10, regex("XXXXX"), "zzzzz");
            string proverka12 = regex_replace(proverka11, regex("XXXX"), "zzzz");

            WIFEND = proverka12;
        }
    }

    // Convert WIFSTART to hex and set RANGE_START
    const char *base58 = WIFSTART.c_str();
    size_t base58Length = WIFSTART.size();
    size_t keybuflen = base58Length == 52 ? 38 : 37;
    unsigned char *keybuf = new unsigned char[keybuflen];
    b58decode(keybuf, &keybuflen, base58, base58Length);

    string nos2 = "";
    for (int i = 0; i < keybuflen; i++)
    {
        char s[32];
        snprintf(s, 32, "%.2x", keybuf[i]);
        string str777(s);
        nos2 = nos2 + str777;
    }
    delete[] keybuf;

    // Use string data instead of local pointer
    RANGE_START.SetBase16((char *)nos2.c_str());
    start1.SetBase16((char *)nos2.c_str());

    // Convert WIFEND to hex and set RANGE_END
    const char *base582 = WIFEND.c_str();
    size_t base58Length2 = WIFEND.size();
    size_t keybuflen2 = base58Length2 == 52 ? 38 : 37;
    unsigned char *keybuf2 = new unsigned char[keybuflen2];
    b58decode(keybuf2, &keybuflen2, base582, base58Length2);

    string nos22 = "";
    for (int i = 0; i < keybuflen2; i++)
    {
        char s2[32];
        snprintf(s2, 32, "%.2x", keybuf2[i]);
        string str7772(s2);
        nos22 = nos22 + str7772;
    }
    delete[] keybuf2;

    RANGE_END.SetBase16((char *)nos22.c_str());

    return true;
}

int main(int argc, char **argv)
{

    printf("\n  Multi-Prefix WifSolver v4.0 ");
    printf("(Thanassiskalv upgrade 03.2025)\n\n");
    double startTime;

    Timer::Init();
    t0 = Timer::get_tick();
    startTime = t0;

    if (readArgs(argc, argv))
    {
        showHelp();
        return 0;
    }
    if (showDevices)
    {
        listDevices();
        return 0;
    }

    dataLen = COMPRESSED ? 38 : 37;

    // For non-prefix mode, setup RANGE_START/END here
    // For prefix mode, this will be set up in the loop for each prefix
    if (!usePrefixMode)
    {
        RANGE_START_TOTAL.Set(&RANGE_START);
        RANGE_TOTAL.Set(&RANGE_END);
        RANGE_TOTAL.Sub(&RANGE_START_TOTAL);
        RANGE_TOTAL_DOUBLE = RANGE_TOTAL.ToDouble();
    }

    if (!checkDevice())
    {
        return -1;
    }

    // Only print config before loop if NOT in prefix mode
    // In prefix mode, config is printed for each prefix setup
    if (!usePrefixMode)
    {
        printConfig();
    }

    // Initialize secp will happen per iteration in the loop
    secp = nullptr;

    auto time = std::chrono::system_clock::now();
    std::time_t s_time = std::chrono::system_clock::to_time_t(time);
    std::cout << "  Start Time      : " << std::ctime(&s_time) << "\n";

    cudaError_t cudaStatus;

    // Prefix loop for dynamic prefix mode
    while (true)
    {
        // Setup next prefix if in prefix mode
        if (usePrefixMode)
        {
            if (currentPrefixIndex >= prefixesList.size())
            {
                printf("  All prefixes processed.\n");
                break;
            }

            // Get current prefix and substitute into WIF
            string prefix = getCurrentPrefix();
            WIF = substitutePrefix(prefix);
            printf("\n  Processing prefix: %s (%zu/%zu)\n", prefix.c_str(), currentPrefixIndex + 1, prefixesList.size());

            // Process WIF and extract WIFSTART
            if (!processPrefixWIF())
            {
                fprintf(stderr, "  ERROR: Failed to process WIF for prefix %s\n", prefix.c_str());
                nextPrefix();
                continue;
            }
            // Verify ranges are valid
            if (!RANGE_START.IsLower(&RANGE_END))
            {
                fprintf(stderr, "  ERROR: Invalid range for prefix %s (START >= END)\n", prefix.c_str());
                fprintf(stderr, "         RANGE_START: %s\n", RANGE_START.GetBase16().c_str());
                fprintf(stderr, "         RANGE_END:   %s\n", RANGE_END.GetBase16().c_str());
                nextPrefix();
                continue;
            }
            // else
            // {
            //     fprintf(stderr, "         RANGE_START: %s\n", RANGE_START.GetBase16().c_str());
            //     fprintf(stderr, "         RANGE_END:   %s\n", RANGE_END.GetBase16().c_str());
            // }
        }

        // Initialize SECP256K1 for this iteration (fresh)
        if (secp != nullptr)
        {
            delete secp;
        }
        secp = new Secp256K1();
        secp->Init();

        // Reset result flag and recalculate ranges
        RESULT = false;
        RANGE_START_TOTAL.Set(&RANGE_START);
        RANGE_TOTAL.Set(&RANGE_END);
        RANGE_TOTAL.Sub(&RANGE_START_TOTAL);
        RANGE_TOTAL_DOUBLE = RANGE_TOTAL.ToDouble();

        // Print config on first iteration (prefix mode shows it per prefix setup)
        if (currentPrefixIndex == 0 || usePrefixMode)
        {
            printConfig();
        }
        t_tmp = Timer::get_tick();

        // Run CUDA processing
        if (unifiedMemory)
        {
            cudaStatus = processCudaUnified();
        }
        else
        {
            cudaStatus = processCuda();
        }

        // Check results and determine next action
        if (RESULT)
        {
            // Found a match, exit successfully
            break;
        }

        if (!usePrefixMode)
        {
            // Not in prefix mode, exit after single iteration
            break;
        }

        // Move to next prefix and continue loop
        nextPrefix();
    }

    time = std::chrono::system_clock::now();
    s_time = std::chrono::system_clock::to_time_t(time);
    std::cout << "\n  End Time        : " << std::ctime(&s_time);

    cudaStatus = cudaDeviceReset();
    if (cudaStatus != cudaSuccess)
    {
        fprintf(stderr, "  Device reset failed!");
        return 1;
    }

    // Cleanup secp
    if (secp != nullptr)
    {
        delete secp;
        secp = nullptr;
    }

    printf("  ---------------------------------\n");
    return 0;
}

cudaError_t processCudaUnified()
{
    cudaError_t cudaStatus;
    uint64_t *buffRangeStart = new uint64_t[NB64BLOCK];
    uint64_t *dev_buffRangeStart = new uint64_t[NB64BLOCK];
    uint64_t *buffStride = new uint64_t[NB64BLOCK];

    const size_t RANGE_TRANSFER_SIZE = NB64BLOCK * sizeof(uint64_t);
    const int COLLECTOR_SIZE_MM = 4 * BLOCK_NUMBER * BLOCK_THREADS;
    const uint32_t expectedChecksum = IS_CHECKSUM ? CHECKSUM.GetInt32() : 0;
    uint64_t counter = 0;

    __Load(buffStride, STRIDE.bits64);
    loadStride(buffStride);
    delete buffStride;

    uint32_t *buffResultManaged = new uint32_t[COLLECTOR_SIZE_MM];
    cudaStatus = cudaMallocManaged(&buffResultManaged, COLLECTOR_SIZE_MM * sizeof(uint32_t));

    for (int i = 0; i < COLLECTOR_SIZE_MM; i++)
    {
        buffResultManaged[i] = UINT32_MAX;
    }

    bool *buffCollectorWork = new bool[1];
    buffCollectorWork[0] = false;
    bool *dev_buffCollectorWork = new bool[1];
    cudaStatus = cudaMalloc((void **)&dev_buffCollectorWork, 1 * sizeof(bool));
    cudaStatus = cudaMemcpy(dev_buffCollectorWork, buffCollectorWork, 1 * sizeof(bool), cudaMemcpyHostToDevice);

    cudaStatus = cudaMalloc((void **)&dev_buffRangeStart, NB64BLOCK * sizeof(uint64_t));

    bool *buffIsResultManaged = new bool[1];
    cudaStatus = cudaMallocManaged(&buffIsResultManaged, 1 * sizeof(bool));
    buffIsResultManaged[0] = false;

    std::chrono::steady_clock::time_point beginCountHashrate = std::chrono::steady_clock::now();
    std::chrono::steady_clock::time_point beginCountStatus = std::chrono::steady_clock::now();

    while (!RESULT && RANGE_START.IsLower(&RANGE_END))
    {
        // prepare launch
        __Load(buffRangeStart, RANGE_START.bits64);
        cudaStatus = cudaMemcpy(dev_buffRangeStart, buffRangeStart, RANGE_TRANSFER_SIZE, cudaMemcpyHostToDevice);
        // launch work
        std::chrono::steady_clock::time_point beginKernel = std::chrono::steady_clock::now();
        if (COMPRESSED)
        {
            if (IS_CHECKSUM)
            {
                kernelCompressed<<<BLOCK_NUMBER, BLOCK_THREADS>>>(buffResultManaged, buffIsResultManaged, dev_buffRangeStart, THREAD_STEPS, expectedChecksum);
            }
            else
            {
                kernelCompressed<<<BLOCK_NUMBER, BLOCK_THREADS>>>(buffResultManaged, buffIsResultManaged, dev_buffRangeStart, THREAD_STEPS);
            }
        }
        else
        {
            if (IS_CHECKSUM)
            {
                kernelUncompressed<<<BLOCK_NUMBER, BLOCK_THREADS>>>(buffResultManaged, buffIsResultManaged, dev_buffRangeStart, THREAD_STEPS, expectedChecksum);
            }
            else
            {
                kernelUncompressed<<<BLOCK_NUMBER, BLOCK_THREADS>>>(buffResultManaged, buffIsResultManaged, dev_buffRangeStart, THREAD_STEPS);
            }
        }
        cudaStatus = cudaGetLastError();
        if (cudaStatus != cudaSuccess)
        {
            fprintf(stderr, "  Kernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
            goto Error;
        }
        cudaStatus = cudaDeviceSynchronize();
        if (cudaStatus != cudaSuccess)
        {
            fprintf(stderr, "  CudaDeviceSynchronize returned error code %d after launching kernel!\n", cudaStatus);
            goto Error;
        }
        int64_t tKernel = std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::steady_clock::now() - beginKernel).count();
        if (buffIsResultManaged[0])
        {
            buffIsResultManaged[0] = false;
            for (int i = 0; i < COLLECTOR_SIZE_MM && !RESULT; i++)
            {
                if (buffResultManaged[i] != UINT32_MAX)
                {
                    Int toTest = new Int(&RANGE_START);
                    Int diff = new Int(&STRIDE);
                    diff.Mult(buffResultManaged[i]);
                    toTest.Add(&diff);
                    processCandidate(toTest);
                    buffResultManaged[i] = UINT32_MAX;
                }
            }
        } // test

        RANGE_START.Add(&loopStride);
        counter += outputSize;
        int64_t tHash = std::chrono::duration_cast<std::chrono::seconds>(std::chrono::steady_clock::now() - beginCountHashrate).count();
        int bubi = 0;
        if (step2 > 8)
        {
            int bubi = 3;
        }
        bubi = 0;
        if (tHash > bubi)
        {
            double speed = (double)((double)counter / tHash) / 1000000.0;
            printSpeed(speed);
            counter = 0;
            beginCountHashrate = std::chrono::steady_clock::now();
        }
        if (std::chrono::duration_cast<std::chrono::seconds>(std::chrono::steady_clock::now() - beginCountStatus).count() > fileStatusInterval)
        {
            saveStatus();
            beginCountStatus = std::chrono::steady_clock::now();
        }
    } // while

Error:
    cudaFree(dev_buffRangeStart);
    cudaFree(dev_buffCollectorWork);
    cudaFree(buffResultManaged);
    return cudaStatus;
}

cudaError_t processCuda()
{
    cudaError_t cudaStatus;
    uint64_t *buffRangeStart = new uint64_t[NB64BLOCK];
    uint64_t *dev_buffRangeStart = new uint64_t[NB64BLOCK];
    uint64_t *buffStride = new uint64_t[NB64BLOCK];

    int COLLECTOR_SIZE = BLOCK_NUMBER;

    __Load(buffStride, STRIDE.bits64);
    loadStride(buffStride);
    delete buffStride;

    bool *buffDeviceResult = new bool[outputSize];
    bool *dev_buffDeviceResult = new bool[outputSize];
    for (int i = 0; i < outputSize; i++)
    {
        buffDeviceResult[i] = false;
    }
    cudaStatus = cudaMalloc((void **)&dev_buffDeviceResult, outputSize * sizeof(bool));
    cudaStatus = cudaMemcpy(dev_buffDeviceResult, buffDeviceResult, outputSize * sizeof(bool), cudaMemcpyHostToDevice);

    delete buffDeviceResult;

    uint64_t *buffResult = new uint64_t[COLLECTOR_SIZE];
    uint64_t *dev_buffResult = new uint64_t[COLLECTOR_SIZE];
    cudaStatus = cudaMalloc((void **)&dev_buffResult, COLLECTOR_SIZE * sizeof(uint64_t));
    cudaStatus = cudaMemcpy(dev_buffResult, buffResult, COLLECTOR_SIZE * sizeof(uint64_t), cudaMemcpyHostToDevice);

    bool *buffCollectorWork = new bool[1];
    buffCollectorWork[0] = false;
    bool *dev_buffCollectorWork = new bool[1];
    cudaStatus = cudaMalloc((void **)&dev_buffCollectorWork, 1 * sizeof(bool));
    cudaStatus = cudaMemcpy(dev_buffCollectorWork, buffCollectorWork, 1 * sizeof(bool), cudaMemcpyHostToDevice);

    cudaStatus = cudaMalloc((void **)&dev_buffRangeStart, NB64BLOCK * sizeof(uint64_t));

    const uint32_t expectedChecksum = IS_CHECKSUM ? CHECKSUM.GetInt32() : 0;

    uint64_t counter = 0;
    bool anyResult = false;

    size_t RANGE_TRANSFER_SIZE = NB64BLOCK * sizeof(uint64_t);
    size_t COLLECTOR_TRANSFER_SIZE = COLLECTOR_SIZE * sizeof(uint64_t);

    std::chrono::steady_clock::time_point beginCountHashrate = std::chrono::steady_clock::now();
    std::chrono::steady_clock::time_point beginCountStatus = std::chrono::steady_clock::now();

    while (!RESULT && RANGE_START.IsLower(&RANGE_END))
    {
        // prepare launch
        __Load(buffRangeStart, RANGE_START.bits64);
        cudaStatus = cudaMemcpy(dev_buffRangeStart, buffRangeStart, RANGE_TRANSFER_SIZE, cudaMemcpyHostToDevice);
        // launch work
        if (COMPRESSED)
        {
            if (IS_CHECKSUM)
            {
                kernelCompressed<<<BLOCK_NUMBER, BLOCK_THREADS>>>(dev_buffDeviceResult, dev_buffCollectorWork, dev_buffRangeStart, THREAD_STEPS, expectedChecksum);
            }
            else
            {
                kernelCompressed<<<BLOCK_NUMBER, BLOCK_THREADS>>>(dev_buffDeviceResult, dev_buffCollectorWork, dev_buffRangeStart, THREAD_STEPS);
            }
        }
        else
        {
            if (IS_CHECKSUM)
            {
                kernelUncompressed<<<BLOCK_NUMBER, BLOCK_THREADS>>>(dev_buffDeviceResult, dev_buffCollectorWork, dev_buffRangeStart, THREAD_STEPS, expectedChecksum);
            }
            else
            {
                kernelUncompressed<<<BLOCK_NUMBER, BLOCK_THREADS>>>(dev_buffDeviceResult, dev_buffCollectorWork, dev_buffRangeStart, THREAD_STEPS);
            }
        }
        cudaStatus = cudaGetLastError();
        if (cudaStatus != cudaSuccess)
        {
            fprintf(stderr, "  Kernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
            goto Error;
        }
        cudaStatus = cudaDeviceSynchronize();
        if (cudaStatus != cudaSuccess)
        {
            fprintf(stderr, "  CudaDeviceSynchronize returned error code %d after launching kernel!\n", cudaStatus);
            goto Error;
        }

        // if (useCollector) {
        // summarize results
        cudaStatus = cudaMemcpy(buffCollectorWork, dev_buffCollectorWork, sizeof(bool), cudaMemcpyDeviceToHost);
        if (buffCollectorWork[0])
        {
            anyResult = true;
            buffCollectorWork[0] = false;
            cudaStatus = cudaMemcpyAsync(dev_buffCollectorWork, buffCollectorWork, sizeof(bool), cudaMemcpyHostToDevice);
            for (int i = 0; i < COLLECTOR_SIZE; i++)
            {
                buffResult[i] = 0;
            }
            cudaStatus = cudaMemcpy(dev_buffResult, buffResult, COLLECTOR_TRANSFER_SIZE, cudaMemcpyHostToDevice);
            while (anyResult && !RESULT)
            {
                resultCollector<<<BLOCK_NUMBER, 1>>>(dev_buffDeviceResult, dev_buffResult, THREAD_STEPS * BLOCK_THREADS);
                cudaStatus = cudaGetLastError();
                if (cudaStatus != cudaSuccess)
                {
                    fprintf(stderr, "  Kernel 'resultCollector' launch failed: %s\n", cudaGetErrorString(cudaStatus));
                    goto Error;
                }
                cudaStatus = cudaDeviceSynchronize();
                if (cudaStatus != cudaSuccess)
                {
                    fprintf(stderr, "  CudaDeviceSynchronize 'resultCollector' returned error code %d after launching kernel!\n", cudaStatus);
                    goto Error;
                }
                cudaStatus = cudaMemcpy(buffResult, dev_buffResult, COLLECTOR_TRANSFER_SIZE, cudaMemcpyDeviceToHost);
                if (cudaStatus != cudaSuccess)
                {
                    fprintf(stderr, "  CudaMemcpy failed!");
                    goto Error;
                }
                anyResult = false;

                for (int i = 0; i < COLLECTOR_SIZE; i++)
                {
                    if (buffResult[i] != 0xffffffffffff)
                    {
                        Int toTest = new Int(&RANGE_START);
                        Int diff = new Int(&STRIDE);
                        diff.Mult(buffResult[i]);
                        toTest.Add(&diff);
                        processCandidate(toTest);
                        anyResult = true;
                    }
                }
            } // while
        } // anyResult to test
        //}
        /*else {
            //pure output, for debug
            cudaStatus = cudaMemcpy(buffDeviceResult, dev_buffDeviceResult, outputSize * sizeof(bool), cudaMemcpyDeviceToHost);
            if (cudaStatus != cudaSuccess) {
                fprintf(stderr, "cudaMemcpy failed!");
                goto Error;
            }
            for (int i = 0; i < outputSize; i++) {
                if (buffDeviceResult[i]) {
                    Int toTest = new Int(&RANGE_START);
                    Int diff = new Int(&STRIDE);
                    diff.Mult(i);
                    toTest.Add(&diff);
                    processCandidate(toTest);
                }
            }
        } */
        RANGE_START.Add(&loopStride);
        counter += outputSize;
        //_count2 += outputSize;
        int64_t tHash = std::chrono::duration_cast<std::chrono::seconds>(std::chrono::steady_clock::now() - beginCountHashrate).count();
        // int64_t tStatus = std::chrono::duration_cast<std::chrono::seconds>(std::chrono::steady_clock::now() - beginCountStatus).count();
        int bubi = 0;
        if (step2 > 8)
        {
            int bubi = 3;
        }
        if (tHash > bubi)
        {
            double speed = (double)((double)counter / tHash) / 1000000.0;
            printSpeed(speed);
            counter = 0;
            beginCountHashrate = std::chrono::steady_clock::now();
        }
        if (std::chrono::duration_cast<std::chrono::seconds>(std::chrono::steady_clock::now() - beginCountStatus).count() > fileStatusInterval)
        {
            saveStatus();
            beginCountStatus = std::chrono::steady_clock::now();
        }
    } // while

Error:
    cudaFree(dev_buffResult);
    cudaFree(dev_buffDeviceResult);
    cudaFree(dev_buffRangeStart);
    cudaFree(dev_buffCollectorWork);
    return cudaStatus;
}

void saveStatus()
{

    string str77 = to_string(DEVICE_NR);
    string prodol = str77 + Continue777;
    FILE *stat = fopen(prodol.c_str(), "w");
    auto time = std::chrono::system_clock::now();
    std::time_t s_time = std::chrono::system_clock::to_time_t(time);
    if (step2 > 8)
    {
        fprintf(stat, "%s\n", std::ctime(&s_time));
        char wif[53];
        unsigned char *buff = new unsigned char[dataLen];
        fprintf(stat, "WifSolverCuda.exe -wif %s ", wifout.c_str());
        fprintf(stat, "-wif2 %s ", WIFEND.c_str());
        if (!TARGET_ADDRESS.empty())
        {
            fprintf(stat, "-a %s ", TARGET_ADDRESS.c_str());
        }
        fprintf(stat, "-n %d ", step);
        fprintf(stat, "-n2 %d ", step2);
        if (turbo > 0)
        {
            fprintf(stat, "-turbo %d ", turbo);
        }
        fprintf(stat, "-d %d\n", DEVICE_NR);
    }
    else
    {
        if (part1 != "")
        {

            fprintf(stat, "%s\n", std::ctime(&s_time));
            char wif[53];
            unsigned char *buff = new unsigned char[dataLen];
            fprintf(stat, "WifSolverCuda.exe -part1 %s ", part1.c_str());
            fprintf(stat, "-part2 %s ", part2.c_str());
            if (!TARGET_ADDRESS.empty())
            {
                fprintf(stat, "-a %s ", TARGET_ADDRESS.c_str());
            }
            fprintf(stat, "-d %d\n", DEVICE_NR);
        }
        else
        {

            fprintf(stat, "%s\n", std::ctime(&s_time));
            char wif[53];
            unsigned char *buff = new unsigned char[dataLen];
            fprintf(stat, "WifSolverCuda.exe -wif %s ", wifout.c_str());
            fprintf(stat, "-wif2 %s ", WIFEND.c_str());
            if (!TARGET_ADDRESS.empty())
            {
                fprintf(stat, "-a %s ", TARGET_ADDRESS.c_str());
            }
            fprintf(stat, "-n %d ", step);
            if (turbo > 0)
            {
                fprintf(stat, "-turbo %d ", turbo);
            }
            fprintf(stat, "-d %d\n", DEVICE_NR);
        }
    }
    fclose(stat);
}

char *toTimeStr(int sec, char *timeStr)
{
    int h, m, s;
    h = (sec / 3600);
    m = (sec - (3600 * h)) / 60;
    s = (sec - (3600 * h) - (m * 60));
    sprintf(timeStr, "%0*d:%0*d:%0*d", 2, h, 2, m, 2, s);
    return (char *)timeStr;
}

std::string formatThousands(uint64_t x)
{
    char buf[32] = "";

    sprintf(buf, "%llu", x);

    std::string s(buf);

    int len = (int)s.length();

    int numCommas = (len - 1) / 3;

    if (numCommas == 0)
    {
        return s;
    }

    std::string result = "";

    int count = ((len % 3) == 0) ? 0 : (3 - (len % 3));

    for (int i = 0; i < len; i++)
    {
        result += s[i];

        if (count++ == 2 && i < len - 1)
        {
            result += ",";
            count = 0;
        }
    }
    return result;
}

void printSpeed(double speed)
{
    char wif[53];
    unsigned char *buff = new unsigned char[dataLen];
    for (int i = 0, d = dataLen - 1; i < dataLen; i++, d--)
    {
        buff[i] = RANGE_START.GetByte(d);
    }

    b58encode(wif, &wifLen, buff, dataLen);
    TurboRotation::Context turboCtx{turbo, zapusk, zcount, zamena, zamena2, zamena3, security, kstr99, alreadyprintedcharacters, RANGE_START, down, WIFSTART, step};
    TurboRotation::spin(turboCtx, std::string(wif));


    if (part1 != "")
    {

        zapusk += 1;

        if (zapusk > 30)
        {
            srand(time(NULL));
            int N = kusok;
            char str[]{"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"};
            int strN = 58;
            char *pass = new char[N + 1];
            for (int i = 0; i < N; i++)
            {
                pass[i] = str[rand() % strN];
            }
            pass[N] = 0;
            std::stringstream ss8;
            ss8 << part1.c_str() << pass << part2.c_str();
            string rannd = ss8.str();

            const char *base58 = rannd.c_str();
            size_t base58Length = rannd.size();
            size_t keybuflen = base58Length == 52 ? 38 : 37;
            unsigned char *keybuf = new unsigned char[keybuflen];
            b58decode(keybuf, &keybuflen, base58, base58Length);

            string nos2 = "";
            for (int i = 0; i < keybuflen; i++)
            {
                char s[32];
                snprintf(s, 32, "%.2x", keybuf[i]);
                string str777(s);
                nos2 = nos2 + str777;
            }
            char *cstr959 = &nos2[0];
            RANGE_START.SetBase16(cstr959);
            zapusk = 0;
        }
    }

    Int ttal;
    ttal.Set(&RANGE_START);
    ttal.Sub(&start1);
    ttal.Div(&STRIDE);
    string totalx = ttal.GetBase10().c_str();
    uint64_t vtotal;
    std::istringstream iss(totalx);
    iss >> vtotal;

    // Calculate speed based on elapsed time for current prefix, not total program time
    double elapsed_time = t1 - t0 - t_tmp;
    if (elapsed_time < 0.1)
        elapsed_time = 0.1; // Avoid division by zero
    uint64_t spedturbo = (uint64_t)(vtotal / elapsed_time);
    uint64_t speedx;
    string valx;
    if (spedturbo < 1000000)
    {
        valx = " Mkey/s";
    }
    else
    {

        if (spedturbo < 1000000000)
        {
            speedx = spedturbo / 1000;
            valx = " Mkey/s";
        }
        else
        {

            if (spedturbo < 1000000000000)
            {
                valx = " Gkey/s";
                speedx = spedturbo / 1000000;
            }
            else
            {
                if (spedturbo < 1000000000000000)
                {
                    valx = " Tkey/s";
                    speedx = spedturbo / 1000000000;
                }
                else
                {
                    valx = " Pkeys/s";
                    speedx = spedturbo / 1000000000000;
                }
            }
        }
    }

    Int ttal2;
    ttal2.Set(&RANGE_END);
    ttal2.Sub(&RANGE_START);
    ttal2.Div(&STRIDE);
    string ost = ttal2.GetBase10().c_str();
    uint64_t ostatok;
    std::istringstream iss2(ost);
    iss2 >> ostatok;
    int sekki = ostatok / 10000000000;

    if (sekki < 86400)
    {
        int h, m, s;
        h = (sekki / 3600);
        m = (sekki - (3600 * h)) / 60;
        s = (sekki - (3600 * h) - (m * 60));
        sprintf(timeStr2, "%0*d:%0*d:%0*d", 2, h, 2, m, 2, s);
    }
    else
    {
        if (sekki < 31536000)
        {
            int d, h, m, s;
            d = sekki / 86400;
            sekki = sekki - (d * 86400);
            h = (sekki / 3600);
            m = (sekki - (3600 * h)) / 60;
            s = (sekki - (3600 * h) - (m * 60));
            sprintf(timeStr2, "%d days %0*d:%0*d:%0*d", d, 2, h, 2, m, 2, s);
        }
        else
        {
            if (sekki < 1734480000)
            {
                int y, d, h, m, s;
                y = sekki / 31536000;
                sekki = sekki - (y * 31536000);
                d = sekki / 86400;
                sekki = sekki - (d * 86400);
                h = (sekki / 3600);
                m = (sekki - (3600 * h)) / 60;
                s = (sekki - (3600 * h) - (m * 60));
                sprintf(timeStr2, "%d years %d days %0*d:%0*d:%0*d", y, d, 2, h, 2, m, 2, s);
            }
            else
            {
                int h, m, s;
                h = 88;
                m = 88;
                s = 88;
                sprintf(timeStr2, "%0*d:%0*d:%0*d", 2, h, 2, m, 2, s);
            }
        }
    }

    t1 = Timer::get_tick();
    Int processedCount = new Int(&RANGE_START);
    processedCount.Sub(&RANGE_START_TOTAL);
    double _count = processedCount.ToDouble();
    _count = _count / RANGE_TOTAL_DOUBLE;
    _count *= 100;
    num_str = to_string(_count);
    nitro = to_string(zcount);
    wifout = wif;
    string num_gpu = to_string(DEVICE_NR);

    if (turbo > 0)
    {
        printf("\r Speed:  [%s] [%s] [S: %s%s] [C: %.3f%%] [T: %s]  ", toTimeStr(t1, timeStr), wif, formatThousands(speedx).c_str(), valx.c_str(), _count, formatThousands(vtotal).c_str());
    }
    else
    {
        if (step2 > 8 || part1 != "")
        {
            std::string speedStr;
            if (speed < 0.01)
            {
                speedStr = "< 0.01 MKey/s";
            }
            else
            {
                if (speed < 1000)
                {
                    speedStr = formatDouble("%.3f", speed) + " Mkey/s";
                }
                else
                {
                    speed /= 1000;
                    if (speed < 1000)
                    {
                        speedStr = formatDouble("%.3f", speed) + " Gkey/s";
                    }
                    else
                    {
                        speed /= 1000;
                        speedStr = formatDouble("%.3f", speed) + " Tkey/s";
                    }
                }
            }
            printf("\r  [%s] [%s] [S: %s]  ", toTimeStr(t1, timeStr), wif, speedStr.c_str());
        }
        else
        {
            printf("\r  [%s] [%s] [S: %s%s] [C: %.3f%%] [T: %s]  ", toTimeStr(t1, timeStr), wif, formatThousands(speedx).c_str(), valx.c_str(), _count, formatThousands(vtotal).c_str());
        }
    }
    if (step2 > 8)
    {
        RANGE_START.Set(&start1);
        shagi.Add(&STRIDE2);
        RANGE_START.Add(&shagi);
    }

    fflush(stdout);
}

void processCandidate(Int &toTest)
{
    FILE *keys;
    char rmdhash[21], address[50], wif[53];
    unsigned char *buff = new unsigned char[dataLen];
    for (int i = 0, d = dataLen - 1; i < dataLen; i++, d--)
    {
        buff[i] = toTest.GetByte(d);
    }
    toTest.SetBase16((char *)toTest.GetBase16().substr(2, 64).c_str());
    Point publickey = secp->ComputePublicKey(&toTest);
    if (p2sh)
    {
        secp->GetHash160(P2SH, true, publickey, (unsigned char *)rmdhash);
    }
    else
    {
        secp->GetHash160(P2PKH, COMPRESSED, publickey, (unsigned char *)rmdhash);
    }
    addressToBase58(rmdhash, address, p2sh);
    if (!TARGET_ADDRESS.empty())
    {
        if (TARGET_ADDRESS == address)
        {
            RESULT = true;
            printf("\n  ===============================================================================\n");
            printf("  Target BTC address: %s\n", address);
            printf("  Private key: %s\n", toTest.GetBase16().c_str());
            if (b58encode(wif, &wifLen, buff, dataLen))
            {
                printf("  WIF key    : %s\n", wif);
            }
            printf("  ===============================================================================\n");
            keys = fopen(fileResult.c_str(), "a+");
            fprintf(keys, "%s\n", address);
            fprintf(keys, "%s\n", wif);
            fprintf(keys, "%s\n\n", toTest.GetBase16().c_str());
            fclose(keys);
            return;
        }
    }
    else
    {
        printf("\n  ===============================================================================\n");
        printf("  Address    : %s\n", address);
        printf("  Private key: %s\n", toTest.GetBase16().c_str());
        if (b58encode(wif, &wifLen, buff, dataLen))
        {
            printf("  WIF key    : %s\n", wif);
        }
        printf("  ===============================================================================\n");
        keys = fopen(fileResultPartial.c_str(), "a+");
        fprintf(keys, "%s\n", address);
        fprintf(keys, "%s\n", wif);
        fprintf(keys, "%s\n\n", toTest.GetBase16().c_str());
        fclose(keys);
    }
}

void printConfig()
{

    // if (COMPRESSED)
    // {
    //     printf("  Search mode     : COMPRESSED\n");
    // }
    // else
    // {
    //     printf("  Search mode     : UNCOMPRESSED\n");
    // }
    if (part1 != "")
    {

        if (!TARGET_ADDRESS.empty())
        {
            printf("  WIF key part 1  : %s (%d characters)\n", part1.c_str(), part1.length());
            printf("  WIF key part 2  : %s (%d characters)\n", part2.c_str(), part2.length());
            int N = kusok;
            char str[]{"XXXXXXXXXXXXXXXX"};
            int strN = 16;
            char *pass = new char[N + 1];
            for (int i = 0; i < N; i++)
            {
                pass[i] = str[rand() % strN];
            }
            pass[N] = 0;
            std::stringstream ss;
            ss << part1.c_str() << pass << part2.c_str();
            std::string inputkus = ss.str();
            std::stringstream ss999;
            ss999 << pass;
            std::string partrange = ss999.str();

            printf("  Random WIF range: %s (%d characters) \n", pass, partrange.length());
            printf("  Starting WIF key: ");
            printf("%s", part1.c_str());
            printf("%s", pass);
            printf("%s", part2.c_str());
            printf(" (%d)\n", inputkus.length());
            // printf("  Position chars  : %d (+ random every ~30 sec.)\n", step);
            printf("  Target BTC Address     : %s\n", TARGET_ADDRESS.c_str());
        }
    }
    else
    {

        string str0;
        string kstr0;
        string s7777 = WIFSTART;
        int konec = s7777.length();
        str0 = s7777.substr(0, konec + 1 - step);
        kstr0 = s7777.substr(konec + 1 - step, konec + 1);
        printf("  WIF START       : ");
        printf("%s", str0.c_str());
        printf("-%s\n", kstr0.c_str());
        printf("  WIF END         : %s\n", WIFEND.c_str());
        if (!TARGET_ADDRESS.empty())
        {
            printf("  Target BTC Address     : %s\n", TARGET_ADDRESS.c_str());
        }
        string str22;
        string kstr22;
        string kstr222;
        string s777722 = WIFSTART;
        int konec22 = s777722.length();
        str22 = s777722.substr(0, konec22 + 1 - step - 1);
        kstr22 = s777722.substr(konec22 - 1 - step + 1, 1);
        kstr222 = s777722.substr(konec22 - step + 1, konec22 - 1);

        // printf("  Position chars  : %s", str22.c_str());
        // printf("%s", kstr22.c_str());
        // printf("%s \n", kstr222.c_str());
        // printf("  Position chars  : %d \n", step);

        if (step2 > 8)
        {
            string str33;
            string kstr33;
            string kstr333;
            string s777733 = WIFSTART;
            int konec33 = s777733.length();
            str33 = s777733.substr(0, konec33 + 1 - step2 - 1);
            kstr33 = s777733.substr(konec33 - 1 - step2 + 1, 1);
            kstr333 = s777733.substr(konec33 - step2 + 1, konec33 - 1);

            printf("  Position chars2 : %s", str33.c_str());
            printf("%s", kstr33.c_str());
            printf("%s \n", kstr333.c_str());
            printf("  Position chars2 : %d (every sec +1)\n", step2);
        }
        else
        {
            Int combint;
            combint.Set(&RANGE_END);
            combint.Sub(&RANGE_START);
            combint.Div(&STRIDE);
            string summcomb = combint.GetBase10().c_str();
            uint64_t comb2;
            std::istringstream iss3(summcomb);
            iss3 >> comb2;
            if (comb2 > 18446744073709551600) // 18446744073709551600)
            {
                printf("  Combinations    : huge number, greater than %s \n", formatThousands(comb2).c_str());
            }
            else
            {
                printf("  Combinations    : %s X %lu \n", formatThousands(comb2).c_str(), prefixesList.size());
            }
        }
        if (turbo == 0) {

            printf("  TURBO MODE      : OFF\n");
        }
        else {

            printf("  TURBO MODE      :");
            printf(" ON ");
            printf("(every 30 sec)\n");

        }
    }
}

bool checkDevice()
{
    cudaError_t cudaStatus = cudaSetDevice(DEVICE_NR);
    if (cudaStatus != cudaSuccess)
    {
        fprintf(stderr, "  Device %d failed!", DEVICE_NR);
        return false;
    }
    else
    {
        cudaDeviceProp props;
        cudaStatus = cudaGetDeviceProperties(&props, DEVICE_NR);
        if (props.canMapHostMemory == 0)
        {
            printf("  Unified memory not supported\n");
            unifiedMemory = 0;
        }
        printf("  Number GPU      : %d (%s %2d procs)\n", DEVICE_NR, props.name, props.multiProcessorCount);
        if (BLOCK_NUMBER == 0)
        {
            BLOCK_NUMBER = props.multiProcessorCount * 8;
        }
        if (BLOCK_THREADS == 0)
        {
            BLOCK_THREADS = (props.maxThreadsPerBlock / 8) * 5;
        }
        outputSize = BLOCK_NUMBER * BLOCK_THREADS * THREAD_STEPS;
        loopStride = new Int(&STRIDE);
        loopStride.Mult(outputSize);
    }
    return true;
}

void showHelp()
{

    printf("-wif             START WIF key 5.... (51 characters) or L..., K...., (52 characters)  \n");
    printf("-wif2            END WIF key 5.... (51 characters) or L..., K...., (52 characters)  \n");
    printf("-a               Bitcoin address 1.... or 3.....\n");
    printf("-n               Letter number from left to right from 9 to 51 \n");
    printf("-n2              Spin additional letters -n2 from 9 to 51 (every sec +1) \n");
    printf("-turbo           Quick mode (skip 3 identical letters in a row) -turbo 3 (default: OFF) \n");
    printf("-part1           First part of the key starting with K, L or 5 (for random mode) \n");
    printf("-part2           The second part of the key with a checksum (for random mode) \n");
    printf("-lprfx           Prefix file for dynamic prefix mode (replaces YYYYY in WIF) \n");
    printf("-fresult         The name of the output file about the find (default: FOUND.txt)\n");
    printf("-fname           The name of the checkpoint save file to continue (default: GPUid + Continue.txt) \n");
    printf("-ftime           Save checkpoint to continue every sec (default %d sec) \n", fileStatusInterval);
    printf("-d               DeviceId. Number GPU (default 0)\n");
    printf("-list            Shows available devices \n");
    printf("-h               Shows help page\n");
}

bool readArgs(int argc, char **argv)
{
    int a = 1;
    bool isStride = false;
    bool isStart = false;
    bool isEnd = false;
    while (a < argc)
    {
        if (strcmp(argv[a], "-h") == 0)
        {
            return true;
        }
        else if (strcmp(argv[a], "-decode555") == 0)
        {
            a++;
            WIF_TO_DECODE = string(argv[a]);
            DECODE = true;
            return false;
        }
        else if (strcmp(argv[a], "-list") == 0)
        {
            showDevices = true;
            return false;
        }
        else if (strcmp(argv[a], "-d") == 0)
        {
            a++;
            DEVICE_NR = strtol(argv[a], NULL, 10);
        }
        else if (strcmp(argv[a], "-c") == 0)
        {
            COMPRESSED = true;
        }
        else if (strcmp(argv[a], "-u") == 0)
        {
            COMPRESSED = false;
            if (p2sh)
            {
                COMPRESSED = true;
            }
        }
        else if (strcmp(argv[a], "-t") == 0)
        {
            a++;
            BLOCK_THREADS = strtol(argv[a], NULL, 10);
        }
        else if (strcmp(argv[a], "-turbo") == 0)
        {
            a++;
            turbo = strtol(argv[a], NULL, 10);
        }
        else if (strcmp(argv[a], "-b") == 0)
        {
            a++;
            BLOCK_NUMBER = strtol(argv[a], NULL, 10);
        }
        else if (strcmp(argv[a], "-s") == 0)
        {
            a++;
            THREAD_STEPS = strtol(argv[a], NULL, 10);
        }
        else if (strcmp(argv[a], "-stride555") == 0)
        {
            a++;
            STRIDE.SetBase16((char *)string(argv[a]).c_str());
            isStride = true;
        }
        else if (strcmp(argv[a], "-fresult") == 0)
        {
            a++;
            fileResult = string(argv[a]);
        }
        else if (strcmp(argv[a], "-fresultp") == 0)
        {
            a++;
            fileResultPartial = string(argv[a]);
        }
        else if (strcmp(argv[a], "-fname") == 0)
        {
            a++;
            Continue777 = string(argv[a]);
        }
        else if (strcmp(argv[a], "-ftime") == 0)
        {
            a++;
            fileStatusInterval = strtol(argv[a], NULL, 10);
        }
        else if (strcmp(argv[a], "-n") == 0)
        {
            a++;
            step = strtol(argv[a], NULL, 10);
        }
        else if (strcmp(argv[a], "-n2") == 0)
        {
            a++;
            step2 = strtol(argv[a], NULL, 10);
        }
        else if (strcmp(argv[a], "-a") == 0)
        {
            a++;
            TARGET_ADDRESS = string(argv[a]);
            if (argv[a][0] == '3')
            {
                p2sh = true;
                COMPRESSED = true;
            }
        }
        else if (strcmp(argv[a], "-wif") == 0)
        {
            a++;
            WIF = string(argv[a]);
        }
        else if (strcmp(argv[a], "-wif2") == 0)
        {
            a++;
            WIF999 = string(argv[a]);
        }
        else if (strcmp(argv[a], "-part1") == 0)
        {
            a++;
            part1 = string(argv[a]);
        }
        else if (strcmp(argv[a], "-part2") == 0)
        {
            a++;
            part2 = string(argv[a]);
        }
        else if (strcmp(argv[a], "-checksum555") == 0)
        {
            a++;
            CHECKSUM.SetBase16((char *)string(argv[a]).c_str());
            IS_CHECKSUM = true;
        }
        else if (strcmp(argv[a], "-yprefixes") == 0)
        {
            a++;
            usePrefixMode = true;
            prefixesFile = string(argv[a]);
        }
        else if (strcmp(argv[a], "-disable-um555") == 0)
        {
            unifiedMemory = 0;
            printf("  Unified memory mode disabled\n");
        }
        a++;
    }

    // Handle prefix mode
    if (usePrefixMode)
    {
        if (!loadPrefixesFromFile(prefixesFile))
        {
            return -1;
        }

        // Store WIF template for later prefix substitution
        if (WIF != "")
        {
            wifTemplate = WIF;
        }
        else
        {
            fprintf(stderr, "  ERROR: -yprefixes mode requires -wif parameter with YYYYY placeholder\n\n");
            return -1;
        }

        // Verify template has placeholder
        if (wifTemplate.find(prefixPlaceholder) == string::npos)
        {
            fprintf(stderr, "  ERROR: WIF template does not contain '%s' placeholder\n\n", prefixPlaceholder.c_str());
            return -1;
        }
    }

    if (WIF[0] == '5')
    {
        COMPRESSED = false;
    }
    if (part1 != "")
    {

        if (part1[0] == 'K' || part1[0] == 'L')
        {

            int konec1 = part1.length();
            int konec2 = part2.length();
            int delka = konec1 + konec2;
            kusok = 52 - delka;
            step = konec2 + 1;
        }
        if (part1[0] == '5')
        {

            COMPRESSED = false;
            int konec1 = part1.length();
            int konec2 = part2.length();
            int delka = konec1 + konec2;
            kusok = 51 - delka;
            step = konec2 + 1;
        }
    }
    if (part2 != "")
    {

        if (part2.length() < 8)
        {
            printf("\n  ERROR WIF     : Mistake! Your WIF key part length! Minimum part2 -> 8 characters\n\n");
            return -1;
        }
    }
    if (WIF != "")
    {

        if (WIF.length() < 51)
        {
            int oshibka = WIF.length();

            printf("\n  ERROR WIF     : Mistake! Your WIF key %s is of length %d! \n  Uncompressed WIF key = 51 characters and start with  5........  \n  Compressed WIF key = 52 characters and start with K.... or L....\n\n", WIFSTART.c_str(), oshibka);
            return -1;
        }
        if (WIF.length() > 52)
        {
            int oshibka = WIF.length();

            printf("\n  ERROR WIF     : Mistake! Your WIF key %s is of length %d! \n  Uncompressed WIF key = 51 characters and start with  5........  \n  Compressed WIF key = 52 characters and start with K.... or L....\n\n", WIFSTART.c_str(), oshibka);
            return -1;
        }

        // If in prefix mode, prepare first WIF with first prefix before processing
        if (usePrefixMode)
        {
            WIF = substitutePrefix(getCurrentPrefix());
        }

        string wifs = WIF;
        int asciiArray[256];
        char ch;
        int charconv;
        for (int i = 0; i < 256; i++)
            asciiArray[i] = 0;
        for (unsigned int i = 0; i < wifs.length(); i++)
        {
            ch = wifs[i];
            charconv = static_cast<int>(ch);
            asciiArray[charconv]++;
        }

        for (unsigned int i = 0; i < wifs.length(); i++)
        {
            char static alreadyprinted;
            char ch = wifs[i];

            if ((asciiArray[ch] > 2) && (ch != alreadyprinted) && (find(alreadyprintedcharacters.begin(), alreadyprintedcharacters.end(), ch) == alreadyprintedcharacters.end()))
            {
                string proverka = wifs;

                string proverka1 = regex_replace(proverka, regex("XXXXXXXXXXXXXXX"), "111111111111111");
                string proverka2 = regex_replace(proverka1, regex("XXXXXXXXXXXXXX"), "11111111111111");
                string proverka3 = regex_replace(proverka2, regex("XXXXXXXXXXXXX"), "1111111111111");
                string proverka4 = regex_replace(proverka3, regex("XXXXXXXXXXXX"), "111111111111");
                string proverka5 = regex_replace(proverka4, regex("XXXXXXXXXXX"), "11111111111");
                string proverka6 = regex_replace(proverka5, regex("XXXXXXXXXX"), "1111111111");
                string proverka7 = regex_replace(proverka6, regex("XXXXXXXXX"), "111111111");
                string proverka8 = regex_replace(proverka7, regex("XXXXXXXX"), "11111111");
                string proverka9 = regex_replace(proverka8, regex("XXXXXXX"), "1111111");
                string proverka10 = regex_replace(proverka9, regex("XXXXXX"), "111111");
                string proverka11 = regex_replace(proverka10, regex("XXXXX"), "11111");
                string proverka12 = regex_replace(proverka11, regex("XXXX"), "1111");
                WIFSTART = proverka12;
            }
        }
    }
    if (WIF != "")
    {

        string wife = WIF;
        int asciiArray[256];
        char ch;
        int charconv;
        for (int i = 0; i < 256; i++)
            asciiArray[i] = 0;
        for (unsigned int i = 0; i < wife.length(); i++)
        {
            ch = wife[i];
            charconv = static_cast<int>(ch);
            asciiArray[charconv]++;
        }

        for (unsigned int i = 0; i < wife.length(); i++)
        {
            char static alreadyprinted;
            char ch = wife[i];

            if ((asciiArray[ch] > 2) && (ch != alreadyprinted) && (find(alreadyprintedcharacters.begin(), alreadyprintedcharacters.end(), ch) == alreadyprintedcharacters.end()))
            {
                string proverkae = wife;

                string proverkae1 = regex_replace(proverkae, regex("XXXXXXXXXXXXXXX"), "zzzzzzzzzzzzzzz");
                string proverkae2 = regex_replace(proverkae1, regex("XXXXXXXXXXXXXX"), "zzzzzzzzzzzzzz");
                string proverkae3 = regex_replace(proverkae2, regex("XXXXXXXXXXXXX"), "zzzzzzzzzzzzz");
                string proverkae4 = regex_replace(proverkae3, regex("XXXXXXXXXXXX"), "zzzzzzzzzzzz");
                string proverkae5 = regex_replace(proverkae4, regex("XXXXXXXXXXX"), "zzzzzzzzzzz");
                string proverkae6 = regex_replace(proverkae5, regex("XXXXXXXXXX"), "zzzzzzzzzz");
                string proverkae7 = regex_replace(proverkae6, regex("XXXXXXXXX"), "zzzzzzzzz");
                string proverkae8 = regex_replace(proverkae7, regex("XXXXXXXX"), "zzzzzzzz");
                string proverkae9 = regex_replace(proverkae8, regex("XXXXXXX"), "zzzzzzz");
                string proverkae10 = regex_replace(proverkae9, regex("XXXXXX"), "zzzzzz");
                string proverkae11 = regex_replace(proverkae10, regex("XXXXX"), "zzzzz");
                string proverkae12 = regex_replace(proverkae11, regex("XXXX"), "zzzz");

                if (proverkae12 == wife)
                {

                    if (COMPRESSED)
                    {
                        WIFEND = "L5oLkpV3aqBjhki6LmvChTCV6odsp4SXM6FfU2Gppt5kFLaHLuZ9";
                    }
                    else
                    {
                        WIFEND = "5Km2kuu7vtFDPpxywn4u3NLpbr5jKpTB3jsuDU2KYEqetqj84qw";
                    }
                }
                else
                {
                    WIFEND = proverkae12;
                }

                if (WIF999 != "")
                {
                    WIFEND = WIF999;
                }
            }
        }
    }
    if (WIF == "")
    {

        if (part1 != "")
        {
            srand(time(NULL));
            int N = kusok;
            char str[]{"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"};
            int strN = 58;
            char *pass = new char[N + 1];
            for (int i = 0; i < N; i++)
            {
                pass[i] = str[rand() % strN];
            }
            pass[N] = 0;
            std::stringstream ss7;
            ss7 << part1.c_str() << pass << part2.c_str();
            WIFSTART = ss7.str();
            WIFEND = "L5oLkpV3aqBjhki6LmvChTCV6odsp4SXM6FfU2Gppt5k7NVCBwG4";
        }
        else
        {
            WIFSTART = "KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn";
            WIFEND = "L5oLkpV3aqBjhki6LmvChTCV6odsp4SXM6FfU2Gppt5k7NVCBwG4";
        }
    }
    if (step == 0)
    {
        step = 9;
    }

    const char *base58 = WIFSTART.c_str();
    size_t base58Length = WIFSTART.size();
    size_t keybuflen = base58Length == 52 ? 38 : 37;
    unsigned char *keybuf = new unsigned char[keybuflen];
    b58decode(keybuf, &keybuflen, base58, base58Length);

    string nos2 = "";
    for (int i = 0; i < keybuflen; i++)
    {
        char s[32];
        snprintf(s, 32, "%.2x", keybuf[i]);
        string str777(s);
        nos2 = nos2 + str777;
    }
    char *cstr959 = &nos2[0];
    RANGE_START.SetBase16(cstr959);
    start1.SetBase16(cstr959);

    const char *base582 = WIFEND.c_str();
    size_t base58Length2 = WIFEND.size();
    size_t keybuflen2 = base58Length2 == 52 ? 38 : 37;
    unsigned char *keybuf2 = new unsigned char[keybuflen2];
    b58decode(keybuf2, &keybuflen2, base582, base58Length2);

    string nos22 = "";
    for (int i = 0; i < keybuflen2; i++)
    {
        char s2[32];
        snprintf(s2, 32, "%.2x", keybuf2[i]);
        string str7772(s2);
        nos22 = nos22 + str7772;
    }
    char *cstr9592 = &nos22[0];
    RANGE_END.SetBase16(cstr9592);

    if (!applyStepStrideConfig(step, step2, STRIDE, STRIDE2, down))
    {
        return -1;
    }
    return false;
}

void listDevices()
{
    int nDevices;
    cudaGetDeviceCount(&nDevices);
    for (int i = 0; i < nDevices; i++)
    {
        cudaDeviceProp prop;
        cudaGetDeviceProperties(&prop, i);
        printf("  Device Number: %d\n", i);
        printf("  %s\n", prop.name);
        if (prop.canMapHostMemory == 0)
        {
            printf("  Unified memory not supported\n");
        }
        printf("  %2d procs\n", prop.multiProcessorCount);
        printf("  MaxThreadsPerBlock: %2d\n", prop.maxThreadsPerBlock);
        printf("  Version majorminor: %d%d\n\n", prop.major, prop.minor);
    }
}