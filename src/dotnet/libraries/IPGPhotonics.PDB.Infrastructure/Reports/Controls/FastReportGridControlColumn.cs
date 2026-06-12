using System;
using System.ComponentModel;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    using SerializerAttribute=FastReportSerializerAttribute;

    internal sealed class FastReportGridControlColumn : FastReportBase,IFastReportClassObject
        {
        [UsedImplicitly][Field(Order=1000202)] public String DataColumn { get; }
        [UsedImplicitly][Field(Order=1000203)] public String HeaderText { get; }
        [UsedImplicitly][Field(Order=1000204)][DefaultValue(FastReportDefaultValueSource.DefaultConstructor)][Serializer(typeof(DataGridViewCellStyleSerializer))] public DataGridViewCellStyle DefaultCellStyle { get; } = new DataGridViewCellStyle();
        [UsedImplicitly][Field(Order=1000205,ConverterCulture="en-US")][DefaultValue(100f)] public Single FillWeight { get; } = 100f;
        [UsedImplicitly][Field(Order=1000207)][DefaultValue(true)] public Boolean Visible { get; } = true;
        [UsedImplicitly][Field(Order=1000206)][DefaultValue(100)] public Int32 Width { get; } = 100;
        [UsedImplicitly][Field(Order=1000201,Converter=typeof(SqlEnumConverter<DataGridViewAutoSizeColumnMode>))] public DataGridViewAutoSizeColumnMode AutoSizeMode { get; }
        String IFastReportClassObject.ClassName { get { return "Column"; }}
        }
    }
