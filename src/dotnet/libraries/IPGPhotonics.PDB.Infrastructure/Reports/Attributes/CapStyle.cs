using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<CapStyle>))]
    public enum CapStyle
        {
        /// <summary>
        /// Specifies a line without a cap.
        /// </summary>
        None,
        /// <summary>
        /// Specifies a line with a circle cap.
        /// </summary>
        Circle,
        /// <summary>
        /// Specifies a line with a square cap.
        /// </summary>
        Square,
        /// <summary>
        /// Specifies a line with a diamond cap.
        /// </summary>
        Diamond,
        /// <summary>
        /// Specifies a line with an arrow cap.
        /// </summary>
        Arrow
        }
    }