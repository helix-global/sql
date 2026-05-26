using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<ShapeKind>))]
    public enum ShapeKind
        {
        Rectangle,
        RoundRectangle,
        Ellipse,
        Triangle,
        Diamond
        }
    }