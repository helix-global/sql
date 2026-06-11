using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Reflection;
using System.Windows.Forms;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    using SerializerAttribute=FastReportSerializerAttribute;

    [FastReportClass("GridControl")]
    internal sealed class GridControl : DialogControl
        {
        [UsedImplicitly][Field(Order=1000500,EmptyIfNull = true)] public IList<GridControlColumn> Columns { get; }
        [UsedImplicitly][Field(Order=1000502)] public Boolean AllowUserToAddRows { get; }
        [UsedImplicitly][Field(Order=1000503)] public Boolean AllowUserToDeleteRows { get; }
        [UsedImplicitly][Field(Order=1000514)][DefaultValue(true)] public Boolean ColumnHeadersVisible { get; } = true;
        [UsedImplicitly][Field(Order=1000517)][DefaultValue(true)] public Boolean MultiSelect { get; } = true;
        [UsedImplicitly][Field(Order=1000521)][DefaultValue(true)] public Boolean RowHeadersVisible { get; } = true;
        [UsedImplicitly][Field(Order=1000518)][DefaultValue(true)] public Boolean ReadOnly { get; } = true;
        [UsedImplicitly][Field(Order=1000504)][DefaultValue(FastReportDefaultValueSource.DefaultConstructor)][Serializer(typeof(DataGridViewCellStyleSerializer))] public DataGridViewCellStyle AlternatingRowsDefaultCellStyle { get; } = new DataGridViewCellStyle();
        [UsedImplicitly][Field(Order=1000511)][DefaultValue(FastReportDefaultValueSource.DefaultConstructor)][Serializer(typeof(DataGridViewCellStyleSerializer))] public DataGridViewCellStyle ColumnHeadersDefaultCellStyle { get; } = new DataGridViewCellStyle();
        [UsedImplicitly][Field(Order=1000515)][DefaultValue(FastReportDefaultValueSource.DefaultConstructor)][Serializer(typeof(DataGridViewCellStyleSerializer))] public DataGridViewCellStyle DefaultCellStyle { get; } = new DataGridViewCellStyle();
        [UsedImplicitly][Field(Order=1000520)][DefaultValue(FastReportDefaultValueSource.DefaultConstructor)][Serializer(typeof(DataGridViewCellStyleSerializer))] public DataGridViewCellStyle RowHeadersDefaultCellStyle { get; } = new DataGridViewCellStyle();
        [UsedImplicitly][Field(Order=1000524)][DefaultValue(FastReportDefaultValueSource.DefaultConstructor)][Serializer(typeof(DataGridViewCellStyleSerializer))] public DataGridViewCellStyle RowsDefaultCellStyle { get; } = new DataGridViewCellStyle();
        [UsedImplicitly][Field(Order=1000505,Converter=typeof(SqlEnumConverter<DataGridViewAutoSizeColumnsMode>))][DefaultValue(DataGridViewAutoSizeColumnsMode.None)] public DataGridViewAutoSizeColumnsMode AutoSizeColumnsMode { get; } = DataGridViewAutoSizeColumnsMode.None;
        [UsedImplicitly][Field(Order=1000506,Converter=typeof(SqlEnumConverter<DataGridViewAutoSizeRowsMode>))][DefaultValue(DataGridViewAutoSizeRowsMode.None)] public DataGridViewAutoSizeRowsMode AutoSizeRowsMode { get; } = DataGridViewAutoSizeRowsMode.None;
        [UsedImplicitly][Field(Order=1000507,Converter=typeof(SqlColorConverter))] public Color BackgroundColor { get; }
        [UsedImplicitly][Field(Order=1000516,Converter=typeof(SqlColorConverter))] public Color GridColor { get; }
        [UsedImplicitly][Field(Order=1000508,Converter=typeof(SqlEnumConverter<BorderStyle>))][DefaultValue(BorderStyle.FixedSingle)] public BorderStyle BorderStyle { get; } = BorderStyle.FixedSingle;
        [UsedImplicitly][Field(Order=1000509,Converter=typeof(SqlEnumConverter<DataGridViewCellBorderStyle>))][DefaultValue(DataGridViewCellBorderStyle.Single)] public DataGridViewCellBorderStyle CellBorderStyle { get; } = DataGridViewCellBorderStyle.Single;
        [UsedImplicitly][Field(Order=1000510,Converter=typeof(SqlEnumConverter<DataGridViewHeaderBorderStyle>))][DefaultValue(DataGridViewHeaderBorderStyle.Raised)] public DataGridViewHeaderBorderStyle ColumnHeadersBorderStyle { get; } = DataGridViewHeaderBorderStyle.Raised;
        [UsedImplicitly][Field(Order=1000513,Converter=typeof(SqlEnumConverter<DataGridViewColumnHeadersHeightSizeMode>))][DefaultValue(DataGridViewColumnHeadersHeightSizeMode.EnableResizing)] public DataGridViewColumnHeadersHeightSizeMode ColumnHeadersHeightSizeMode { get; } = DataGridViewColumnHeadersHeightSizeMode.EnableResizing;
        [UsedImplicitly][Field(Order=1000519,Converter=typeof(SqlEnumConverter<DataGridViewHeaderBorderStyle>))][DefaultValue(DataGridViewHeaderBorderStyle.Raised)] public DataGridViewHeaderBorderStyle RowHeadersBorderStyle { get; } = DataGridViewHeaderBorderStyle.Raised;
        [UsedImplicitly][Field(Order=1000523,Converter=typeof(SqlEnumConverter<DataGridViewRowHeadersWidthSizeMode>))][DefaultValue(DataGridViewRowHeadersWidthSizeMode.EnableResizing)] public DataGridViewRowHeadersWidthSizeMode RowHeadersWidthSizeMode { get; } = DataGridViewRowHeadersWidthSizeMode.EnableResizing;
        [UsedImplicitly][Field(Order=1000525,Converter=typeof(SqlEnumConverter<ScrollBars>))][DefaultValue(ScrollBars.Both)] public ScrollBars ScrollBars { get; } = ScrollBars.Both;
        [UsedImplicitly][Field(Order=1000526,Converter=typeof(SqlEnumConverter<DataGridViewSelectionMode>))][DefaultValue(DataGridViewSelectionMode.RowHeaderSelect)] public DataGridViewSelectionMode SelectionMode { get; } = DataGridViewSelectionMode.RowHeaderSelect;
        [UsedImplicitly][Field(Order=1000512)][DefaultValue(18)] public Int32 ColumnHeadersHeight { get; } = 18;
        [UsedImplicitly][Field(Order=1000522)][DefaultValue(41)] public Int32 RowHeadersWidth { get; } = 41;
        [UsedImplicitly][Field(Order=1000501)] public String DataSource { get; }

        #region M:CreateObject(String):FastReportObject
        protected override FastReportObject CreateObject(String typeName) {
            switch (typeName) {
                case "Column" : return new GridControlColumn();
                }
            return base.CreateObject(typeName);
            }
        #endregion
        #region M:Serialize(XmlWriter,String,Object)
        public override void Serialize(XmlWriter writer,String prefix,Object other) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            var type = GetType();
            var className = type.GetCustomAttribute<FastReportClassAttribute>(false)?.Name ?? type.Name;
            using (writer.ElementGroup(className)) {
                SerializeAttributes(writer,prefix);
                if ((Columns != null) && (Columns.Count > 0)) {
                    using (writer.ElementGroup("Columns")) {
                        Serialize(writer,Columns,prefix);
                        }
                    }
                foreach (var o in Children) {
                    o.Serialize(writer,prefix,null);
                    }
                }
            }
        #endregion
        #region M:SerializeAttribute(XmlWriter,String,PropertyDescriptor)
        protected override void SerializeAttribute(XmlWriter writer,String prefix,PropertyDescriptor descriptor) {
            if (descriptor.Name == nameof(Columns)) { return; }
            base.SerializeAttribute(writer, prefix, descriptor);
            }
        #endregion
        }
    }
