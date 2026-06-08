using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<DatamatrixSymbolSize>))]
    public enum DatamatrixSymbolSize
        {
        None,
        Auto,
        Size10x10,
        Size12x12,
        Size14x14,
        Size16x16,
        Size18x18,
        Size20x20,
        Size22x22,
        Size24x24,
        Size26x26,
        Size32x32,
        Size36x36,
        Size40x40,
        Size44x44,
        Size48x48,
        Size52x52,
        Size64x64,
        Size72x72,
        Size80x80,
        Size88x88,
        Size96x96,
        Size104x104,
        Size120x120,
        Size132x132,
        Size144x144
        }
    }