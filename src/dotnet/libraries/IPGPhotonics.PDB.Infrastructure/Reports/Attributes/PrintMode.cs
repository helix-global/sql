using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<PrintMode>))]
    internal enum PrintMode
        {
        /// <summary>
        /// Specifies the default printing mode. One report page produces 
        /// one printed paper sheet of the same size.
        /// </summary>
        Default,
        /// <summary>
        /// Specifies the split mode. Big report page produces several smaller paper sheets.
        /// Use this mode to print A3 report on A4 printer.
        /// </summary>
        Split,
        /// <summary>
        /// Specifies the scale mode. One or several report pages produce one bigger paper sheet.
        /// Use this mode to print A5 report on A4 printer. 
        /// </summary>
        Scale
        }
    }
