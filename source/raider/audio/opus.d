module raider.audio.opus;

import raider.tools.reference;
import std.conv : hex = hexString;

/* This is the Opus codec, excluding SILK.
 * 
 * Opus has two internal codecs, SILK and CELT. SILK is excluded here
 * as ultra-low-bitrate voice chat is less than relevant to online gaming.
 * Oh yes, I went there. I'm not afraid to mildly amuse the two or three
 * people in the world who might possibly care in the slightest.
 */
@RC class Decoder
{
    int fs, channels, streamChannels, bandwidth, mode, prevMode;
    int frameSize, prevRedundancy, lastPacketDuration, decodeGain, arch;
    uint rangeFinal; float[2] softclipMem;
    CeltDecoder cdec;
    
    //int celt_dec_offset, silk_dec_offset, channels, fs, decode_gain, arch;
    this(uint fs, uint channels) //opus_decoder_create
    {
        assert(fs == 48_000 || fs == 24_000 || fs == 16_000 || fs == 8_000);
        assert(channels == 1 || channels == 2);
        this.fs = fs;
        this.streamChannels = this.channels = channels;
        //celt_decoder_init
    }
    
    ~this() //opus_decoder_destroy
    {
        
    }
    
    //
    uint decode(ubyte[] data, short[] pcm, bool fec) //opus_decode
    {
        //data null to indicate loss
        //fec true = forward error correction
        
        return 0;
    }
}

////// CELT
struct CeltDecoder //CELTDecoder, alias of OpusCustomDecoder (Seemingly exclusive to CELT)
{
    //Is OpusCustomDecoder somehow redundant?
    //The custom code is used with non-custom modes by default.
    //That's all.
    
    CeltMode* mode;
    int overlap, channels, streamChannels, downsample, start, end, signalling, disableInv, arch;
    
    uint rng;
    int error, lastPitchIndex, lossCount, skipPLC, postfilterPeriod, postfilterPeriodOld;
    float postfilterGain, postfilterGainOld;
    int postfilterTapset, postfilterTapsetOld;
    float[2] preemph_memD;
    float[1][1] _decode_mem;
    
    this(int samplingRate, int channels)
    {
        //CURRENTLY WORKING ON: window120, but also the realisation: opus_valXX and celt_sig / norm / ener are all FLOAT. NOT SHORTS OR WHATNOT. AUGH.
        //Recheck EVERYTHING. It's the only way.
        // OpusCustomMode::
        // opus_decoder_init -> celt_decoder_init -> opus_custom_decoder_init( opus_custom_mode_create() )
        // opus_decoder.c       celt_decoder.c       celt_decoder.c            modes.c
    }
}

immutable short[22] eband5ms = [0,1,2,3,4,5,6,7,8,10,12,14,16,20,24,28,34,40,48,60,78,100];
immutable short[21] logN400 = [0,0,0,0,0,0,0,0,8,8,8,8,16,16,16,21,21,24,29,34,36];
immutable ubyte[11*21] band_allocation = [
      0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     90, 80, 75, 69, 63, 56, 49, 40, 34, 29, 20, 18, 10,  0,  0,  0,  0,  0,  0,  0,  0,
    110,100, 90, 84, 78, 71, 65, 58, 51, 45, 39, 32, 26, 20, 12,  0,  0,  0,  0,  0,  0,
    118,110,103, 93, 86, 80, 75, 70, 65, 59, 53, 47, 40, 31, 23, 15,  4,  0,  0,  0,  0,
    126,119,112,104, 95, 89, 83, 78, 72, 66, 60, 54, 47, 39, 32, 25, 17, 12,  1,  0,  0,
    134,127,120,114,103, 97, 91, 85, 78, 72, 66, 60, 54, 47, 41, 35, 29, 23, 16, 10,  1,
    144,137,130,124,113,107,101, 95, 88, 82, 76, 70, 64, 57, 51, 45, 39, 33, 26, 15,  1,
    152,145,138,132,123,117,111,105, 98, 92, 86, 80, 74, 67, 61, 55, 49, 43, 36, 20,  1,
    162,155,148,142,133,127,121,115,108,102, 96, 90, 84, 77, 71, 65, 59, 53, 46, 30,  1,
    172,165,158,152,143,137,131,125,118,112,106,100, 94, 87, 81, 75, 69, 63, 56, 45, 20,
    200,200,200,200,200,200,200,200,198,193,188,183,178,173,168,163,158,153,148,129,104];

//USE THE HEX TRICK FOR BAND_ALLOCATION
//I forget how I generated this array
immutable dcp = cast(ubyte[120])hex!"
    1807171928062729161A262A38053739151B363A252B48044749141C353B464A242C58454B343C03
    5759131D565A232D444C555B333D68026769121E666A222E545C434D656B323E78017779535D111F
    646C424E767A212F757B313F636D525E00747C414F1020626E30737D515F40727E616F50717F6070";

immutable float[120] window120 = [
    6.7286966e-05f, 0.00060551348f, 0.0016815970f, 0.0032947962f, 0.0054439943f,
    0.0081276923f, 0.011344001f, 0.015090633f, 0.019364886f, 0.024163635f,
    0.029483315f, 0.035319905f, 0.041668911f, 0.048525347f, 0.055883718f,
    0.063737999f, 0.072081616f, 0.080907428f, 0.090207705f, 0.099974111f,
    0.11019769f, 0.12086883f, 0.13197729f, 0.14351214f, 0.15546177f,
    0.16781389f, 0.18055550f, 0.19367290f, 0.20715171f, 0.22097682f,
    0.23513243f, 0.24960208f, 0.26436860f, 0.27941419f, 0.29472040f,
    0.31026818f, 0.32603788f, 0.34200931f, 0.35816177f, 0.37447407f,
    0.39092462f, 0.40749142f, 0.42415215f, 0.44088423f, 0.45766484f,
    0.47447104f, 0.49127978f, 0.50806798f, 0.52481261f, 0.54149077f,
    0.55807973f, 0.57455701f, 0.59090049f, 0.60708841f, 0.62309951f,
    0.63891306f, 0.65450896f, 0.66986776f, 0.68497077f, 0.69980010f,
    0.71433873f, 0.72857055f, 0.74248043f, 0.75605424f, 0.76927895f,
    0.78214257f, 0.79463430f, 0.80674445f, 0.81846456f, 0.82978733f,
    0.84070669f, 0.85121779f, 0.86131698f, 0.87100183f, 0.88027111f,
    0.88912479f, 0.89756398f, 0.90559094f, 0.91320904f, 0.92042270f,
    0.92723738f, 0.93365955f, 0.93969656f, 0.94535671f, 0.95064907f,
    0.95558353f, 0.96017067f, 0.96442171f, 0.96834849f, 0.97196334f,
    0.97527906f, 0.97830883f, 0.98106616f, 0.98356480f, 0.98581869f,
    0.98784191f, 0.98964856f, 0.99125274f, 0.99266849f, 0.99390969f,
    0.99499004f, 0.99592297f, 0.99672162f, 0.99739874f, 0.99796667f,
    0.99843728f, 0.99882195f, 0.99913147f, 0.99937606f, 0.99956527f,
    0.99970802f, 0.99981248f, 0.99988613f, 0.99993565f, 0.99996697f,
    0.99998518f, 0.99999457f, 0.99999859f, 0.99999982f, 1.0000000f,];

struct CeltMode //CELTMode, alias of OpusCustomMode (modes.h)
{
    //This struct is default initialised to mode48000_960_120 (static_modes_float.h 866)
    int fs = 48_000, overlap = 120, nbEBands = 21, effEBands = 21;
    float[4] preemph = [0.85000610f, 0.0f, 1.0f, 1.0f];
    const short* eBands = cast(short*)eband5ms;
    int maxLM = 3, nbShortMdcts = 8, shortMdctSize = 120;
    
    int nbAllocVectors = 11; //Number of lines in the matrix below
    ubyte* allocVectors = cast(ubyte*)band_allocation; //Number of bits in each band for several rates
    const short* logN = cast(short*)logN400;
    
    const float* window = cast(float*)window120; //UP TO HERE
    MdctLookup mdct;
    PulseCache cache;
    
    this(int fs, int frameSize) //opus_custom_mode_create (modes.c 244)
    {
        assert(fs == 48_000);
        assert(frameSize == 960 || frameSize == 1920 || frameSize == 3840 || frameSize == 7680);
        //Just check and assign fs and frameSize..
        /*
        CeltMode cm; //replace this
        //modes.c iterates through TOTAL_MODES static modes, but TOTAL_MODES is always 1.
        //Without custom modes, there is LITERALLY ONLY ONE MODE.
        //Consider setting fields to this mode and restricting fs and frameSize to compatible arguments.
        
        foreach(j; 0..4)
        {
            if(fs == cm.fs && (frameSize << j) == cm.shortMdctSize * cm.nbShortMdcts) {
                //Set to cm and return / break.
            }
        }
        */
    }
}

struct PulseCache { //PulseCache (modes.h)
    int size;
    const short* index;
    const ubyte* bits, caps;
}

struct MdctLookup { //mdct_lookup (mdct.h)
    int n, maxshift;
    const KissFFT*[4]kfft; //This is either a pointer to an array of four, or an array of four pointers.
    //What does kiss_fft_state *kfft[4]; mean in C?
    const float* trig; //This uses __restrict..
}

struct KissFFT { //kiss_fft_state (kiss_fft.h)
    int nfft; float scale;
    int shift; short[16] factors; //16 = 2*MAXFACTORS(8)
    const short* bitrev;
    KissCPX* twiddles;
    ArchFFT* archFFT;
}

struct ArchFFT { //arch_fft_state
    int isSupported;
    void* priv;
}

struct KissCPX { //kiss_twiddle_cpx AND kiss_fft_cpx - CONSIDER REPLACING WITH complex.
    float r, i;
}

uint packet_get_bandwidth(ubyte[] data) { return 0; }
uint packet_get_samples_per_frame(ubyte[] data, uint fs) { return 0; }
uint packet_get_nb_channels(ubyte[] data) { return 0; }
uint packet_get_nb_frames(ubyte[] data) { return 0; }
uint packet_get_nb_samples(ubyte[] data, uint fs) { return 0; }

/+
FIXED_POINT: NOT DEFINED.
CUSTOM_MODES: NOT DEFINED.
CUSTOM_MODES_ONLY: NOT DEFINED.

IGNORED:
opus_decoder_init - no in-memory init required.
opus_decoder_get_size - ditto
opus_decode_float - we only need 16-bit
opus_decoder_ctl - replaced with .. sanity?
opus_packet_parse - only used once, by decode.
opus_pcm_soft_clip - not using floats

repacketizer - no use case
multistream - no use case
+/
