using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<AutoShrinkMode>))]
    public enum AutoShrinkMode
        {
        None,
        FontSize,
        FontWidth
        }
    }