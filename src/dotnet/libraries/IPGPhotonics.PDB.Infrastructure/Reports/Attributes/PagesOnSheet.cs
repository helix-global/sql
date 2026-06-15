using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<PagesOnSheet>))]
    internal enum PagesOnSheet
        {
        /// <summary>
        /// Specifies one report page per sheet.
        /// </summary>
        One,
        /// <summary>
        /// Specifies two report pages per sheet.
        /// </summary>
        Two,
        /// <summary>
        /// Specifies four report pages per sheet.
        /// </summary>
        Four,
        /// <summary>
        /// Specifies eight report pages per sheet.
        /// </summary>
        Eight
        }
    }
