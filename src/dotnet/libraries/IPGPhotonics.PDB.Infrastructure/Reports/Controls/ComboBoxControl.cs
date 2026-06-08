using System;
using System.ComponentModel;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("ComboBoxControl")]
    internal sealed class ComboBoxControl : DataFilterBaseControl
        {
        [UsedImplicitly][Field(Order=1000611)] public String DrawItemEvent { get; }
        [UsedImplicitly][Field(Order=1000610)] public String MeasureItemEvent { get; }
        [UsedImplicitly][Field(Order=1000609)] public String SelectedIndexChangedEvent { get; }
        [UsedImplicitly][Field(Order=1000608)] public String ItemsText { get; }
        [UsedImplicitly][Field(Order=1000601,Converter=typeof(SqlEnumConverter<DrawMode>))] public DrawMode DrawMode { get; }
        [UsedImplicitly][Field(Order=1000602,Converter=typeof(SqlEnumConverter<ComboBoxStyle>))][DefaultValue(ComboBoxStyle.DropDown)] public ComboBoxStyle DropDownStyle { get; } = ComboBoxStyle.DropDown;
        [UsedImplicitly][Field(Order=1000604)] public Int32 DropDownHeight { get; }
        [UsedImplicitly][Field(Order=1000603)] public Int32 DropDownWidth { get; }
        [UsedImplicitly][Field(Order=1000605)] public Int32 ItemHeight { get; }
        [UsedImplicitly][Field(Order=1000606)][DefaultValue(8)] public Int32 MaxDropDownItems { get; } = 8;
        [UsedImplicitly][Field(Order=1000607)] public Boolean Sorted { get; }
        }
    }