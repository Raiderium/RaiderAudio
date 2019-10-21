module raider.audio.sound;

/**
 * A vibration of the air.
 * 
 * There are three ways to load audio:
 * Effect - Decode a sound file all at once to PCM for quick, repetitious playback
 * Music - Load but do not decode, then stream from memory
 * Stream - Stream from an arbitrary source - file, network, an application, etc
 */
final class Sound
{
	this() { }
    /* Only Effect and Music loading will be implemented for 1.0.
     * Streaming is substantially more complex and may never be implemented. */
}

/* Effect bank - a definition file with timestamps.
 * Automatically opens large files exactly once and creates a dictionary of sounds. */
