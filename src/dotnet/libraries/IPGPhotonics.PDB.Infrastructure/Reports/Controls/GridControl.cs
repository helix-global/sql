using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("GridControl")]
    internal class GridControl : DialogControl
        {
        [UsedImplicitly][Field(EmptyIfNull = true)] public IList<GridControlColumn> Columns { get; }
        [UsedImplicitly][Field] public Boolean AllowUserToAddRows { get; }
        [UsedImplicitly][Field] public Boolean AllowUserToDeleteRows { get; }
        [UsedImplicitly][Field] public Boolean ColumnHeadersVisible { get; } = true;
        [UsedImplicitly][Field] public Boolean MultiSelect { get; } = true;
        [UsedImplicitly][Field] public Boolean RowHeadersVisible { get; } = true;
        [UsedImplicitly][Field] public DataGridViewCellStyle AlternatingRowsDefaultCellStyle { get; }
        [UsedImplicitly][Field] public DataGridViewCellStyle ColumnHeadersDefaultCellStyle { get; }
        [UsedImplicitly][Field] public DataGridViewCellStyle DefaultCellStyle { get; }
        [UsedImplicitly][Field] public DataGridViewCellStyle RowHeadersDefaultCellStyle { get; }
        [UsedImplicitly][Field] public DataGridViewCellStyle RowsDefaultCellStyle { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<DataGridViewAutoSizeColumnsMode>))] public DataGridViewAutoSizeColumnsMode AutoSizeColumnsMode { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<DataGridViewAutoSizeRowsMode>))] public DataGridViewAutoSizeRowsMode AutoSizeRowsMode { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color BackgroundColor { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color GridColor { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<BorderStyle>))] public BorderStyle BorderStyle { get; } = BorderStyle.FixedSingle;
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<DataGridViewCellBorderStyle>))] public DataGridViewCellBorderStyle CellBorderStyle { get; } = DataGridViewCellBorderStyle.Single;
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<DataGridViewHeaderBorderStyle>))] public DataGridViewHeaderBorderStyle ColumnHeadersBorderStyle { get; } = DataGridViewHeaderBorderStyle.Raised;
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<DataGridViewColumnHeadersHeightSizeMode>))] public DataGridViewColumnHeadersHeightSizeMode ColumnHeadersHeightSizeMode { get; } = DataGridViewColumnHeadersHeightSizeMode.EnableResizing;
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<DataGridViewHeaderBorderStyle>))] public DataGridViewHeaderBorderStyle RowHeadersBorderStyle { get; } = DataGridViewHeaderBorderStyle.Raised;
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<DataGridViewRowHeadersWidthSizeMode>))] public DataGridViewRowHeadersWidthSizeMode RowHeadersWidthSizeMode { get; } = DataGridViewRowHeadersWidthSizeMode.EnableResizing;
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<ScrollBars>))] public ScrollBars ScrollBars { get; } = ScrollBars.Both;
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<DataGridViewSelectionMode>))] public DataGridViewSelectionMode SelectionMode { get; } = DataGridViewSelectionMode.RowHeaderSelect;
        [UsedImplicitly][Field] public Int32 ColumnHeadersHeight { get; } = 18;
        [UsedImplicitly][Field] public Int32 RowHeadersWidth { get; } = 41;
        [UsedImplicitly][Field] public String DataSource { get; }
        }
    }
