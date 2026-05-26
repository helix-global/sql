using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<HorzAlign>))]
    public enum HorzAlign
        {
        Left,
        Center,
        Right,
        Justify
        }
    }