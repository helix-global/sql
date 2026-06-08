using System;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class ListBoxBaseControl : DataFilterBaseControl
        {
        [UsedImplicitly][Field(Order=1000601)] public Int32 ColumnWidth { get; }
        [UsedImplicitly][Field(Order=1000603)] public Int32 ItemHeight { get; }
        [UsedImplicitly][Field(Order=1000611)] public String DrawItemEvent { get; }
        [UsedImplicitly][Field(Order=1000610)] public String MeasureItemEvent { get; }
        [UsedImplicitly][Field(Order=1000609)] public String SelectedIndexChangedEvent { get; }
        [UsedImplicitly][Field(Order=1000608)] public String ItemsText { get; }
        [UsedImplicitly][Field(Order=1000604)] public Boolean MultiColumn { get; }
        [UsedImplicitly][Field(Order=1000606)] public Boolean Sorted { get; }
        [UsedImplicitly][Field(Order=1000607)] public Boolean UseTabStops { get; }
        [UsedImplicitly][Field(Order=1000602,Converter=typeof(SqlEnumConverter<DrawMode>))] public DrawMode DrawMode { get; }
        [UsedImplicitly][Field(Order=1000605,Converter=typeof(SqlEnumConverter<SelectionMode>))] public SelectionMode SelectionMode { get; }
        }
    }