using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<PathGradientStyle>))]
    public enum PathGradientStyle
        {
        /// <summary>
        /// Elliptic gradient.
        /// </summary>
        Elliptic,
        /// <summary>
        /// Rectangular gradient.
        /// </summary>
        Rectangular
        }
    }