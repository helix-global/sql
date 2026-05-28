using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<WatermarkTextRotation>))]
    public enum WatermarkTextRotation
        {
        /// <summary>
        /// Specifies a horizontal text.
        /// </summary>
        Horizontal,
        /// <summary>
        /// Specifies a vertical text.
        /// </summary>
        Vertical,
        /// <summary>
        /// Specifies a diagonal text.
        /// </summary>
        ForwardDiagonal,
        /// <summary>
        /// Specifies a backward diagonal text.
        /// </summary>
        BackwardDiagonal
        }
    }