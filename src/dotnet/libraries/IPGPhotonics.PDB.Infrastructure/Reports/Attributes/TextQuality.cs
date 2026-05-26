using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<TextQuality>))]
    public enum TextQuality
        {
        Default,
        Regular,
        ClearType,
        AntiAlias
        }
    }