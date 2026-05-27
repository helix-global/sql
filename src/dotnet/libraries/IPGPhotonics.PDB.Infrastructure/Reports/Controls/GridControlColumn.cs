using System;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal class GridControlColumn : Base
        {
        [UsedImplicitly][Field] public String DataColumn { get; }
        [UsedImplicitly][Field] public String HeaderText { get; }
        [UsedImplicitly][Field] public DataGridViewCellStyle DefaultCellStyle { get; }
        [UsedImplicitly][Field] public Single FillWeight { get; } = 100f;
        [UsedImplicitly][Field] public Boolean Visible { get; } = true;
        [UsedImplicitly][Field] public Int32 Width { get; } = 100;
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<DataGridViewAutoSizeColumnMode>))] public DataGridViewAutoSizeColumnMode AutoSizeMode { get; }
        }
    }
