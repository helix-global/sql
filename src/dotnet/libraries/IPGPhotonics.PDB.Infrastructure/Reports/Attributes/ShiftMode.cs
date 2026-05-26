using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<ShiftMode>))]
    public enum ShiftMode
        {
        Never,
        Always,
        WhenOverlapped
        }
    }