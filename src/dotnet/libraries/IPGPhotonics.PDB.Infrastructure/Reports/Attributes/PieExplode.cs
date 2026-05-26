using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<PieExplode>))]
    public enum PieExplode
        {
        None,
        BiggestValue,
        LowestValue,
        SpecificValue
        }
    }