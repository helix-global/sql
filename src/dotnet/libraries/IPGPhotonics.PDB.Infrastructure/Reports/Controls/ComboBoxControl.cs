using System;
using System.ComponentModel;
using System.Drawing;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("ComboBoxControl")]
    internal sealed class ComboBoxControl : DataFilterBaseControl
        {
        [UsedImplicitly][Field] public String DrawItemEvent { get; }
        [UsedImplicitly][Field] public String MeasureItemEvent { get; }
        [UsedImplicitly][Field] public String SelectedIndexChangedEvent { get; }
        [UsedImplicitly][Field] public String ItemsText { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<DrawMode>))] public DrawMode DrawMode { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<ComboBoxStyle>))] public ComboBoxStyle DropDownStyle { get; } = ComboBoxStyle.DropDown;
        [UsedImplicitly][Field] public Int32 DropDownHeight { get; }
        [UsedImplicitly][Field] public Int32 DropDownWidth { get; }
        [UsedImplicitly][Field] public Int32 ItemHeight { get; }
        [UsedImplicitly][Field] public Int32 MaxDropDownItems { get; } = 8;
        [UsedImplicitly][Field] public Boolean Sorted { get; }
        }
    }