using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<PageRange>))]
    internal enum PageRange
        {
        /// <summary>
        /// Print all pages.
        /// </summary>
        All,
        /// <summary>
        /// Print current page.
        /// </summary>
        Current,
        /// <summary>
        /// Print pages specified in the <b>PageNumbers</b> property of the <b>PrintSettings</b>.
        /// </summary>
        PageNumbers
        }
    }
