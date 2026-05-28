using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<ColumnLayout>))]
    public enum ColumnLayout
        {
        /// <summary>
        /// Print columns across then down.
        /// </summary>
        AcrossThenDown,
        /// <summary>
        /// Print columns down then across.
        /// </summary>
        DownThenAcross
        }
    }