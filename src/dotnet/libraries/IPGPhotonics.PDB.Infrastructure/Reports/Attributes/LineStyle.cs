using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<LineStyle>))]
    public enum LineStyle
        {
        /// <summary>
        /// Specifies a solid line. 
        /// </summary>
        Solid,
        /// <summary>
        /// Specifies a line consisting of dashes.
        /// </summary>
        Dash,
        /// <summary>
        /// Specifies a line consisting of dots. 
        /// </summary>
        Dot,
        /// <summary>
        /// Specifies a line consisting of a repeating pattern of dash-dot. 
        /// </summary>
        DashDot,
        /// <summary>
        /// Specifies a line consisting of a repeating pattern of dash-dot-dot. 
        /// </summary>
        DashDotDot,
        /// <summary>
        /// Specifies a double line. 
        /// </summary>
        Double
        }
    }