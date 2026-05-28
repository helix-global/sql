using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<WatermarkImageSize>))]
    public enum WatermarkImageSize
        {
        /// <summary>
        /// Specifies the normal (original) size.
        /// </summary>
        Normal,
        /// <summary>
        /// Specifies the centered image.
        /// </summary>
        Center,
        /// <summary>
        /// Specifies the stretched image.
        /// </summary>
        Stretch,
        /// <summary>
        /// Specifies the stretched image that keeps its aspect ratio.
        /// </summary>
        Zoom,
        /// <summary>
        /// Specifies the tiled image.
        /// </summary>
        Tile
        }
    }