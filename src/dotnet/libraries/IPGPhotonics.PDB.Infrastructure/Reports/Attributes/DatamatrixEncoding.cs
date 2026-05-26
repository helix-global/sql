using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<DatamatrixEncoding>))]
    public enum DatamatrixEncoding
        {
        Auto,
        Ascii,
        C40,
        Text,
        Base256,
        X12,
        Edifact
        }
    }