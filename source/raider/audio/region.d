module raider.audio.region;

/**
 * A volume in a medium.
 * 
 * Regions model interior environments, adding reverb
 * and changing the way sound propagates. For example,
 * the inside of a plane. Sound propagates normally 
 * inside, no matter what speed air is rushing around
 * outside.
 * 
 * Note that playing a sound inside a moving region
 * requires two sets of waves, for listeners inside
 * and outside the region. One set moves with the 
 * region, the other moves with the medium. They
 * sound different depending on the properties of the
 * region.
 */
final class Region
{

}
