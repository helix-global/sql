using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<PrintPages>))]
    internal enum PrintPages
        {
        /// <summary>
        /// Print all report pages.
        /// </summary>
        All,
        /// <summary>
        /// Print odd pages only.
        /// </summary>
        Odd,
        /// <summary>
        /// Print even pages only.
        /// </summary>
        Even
        }
    }
