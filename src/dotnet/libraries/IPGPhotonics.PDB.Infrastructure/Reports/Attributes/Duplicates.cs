using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<Duplicates>))]
    public enum Duplicates
        {
        Show,
        Hide,
        Clear,
        Merge
        }
    }