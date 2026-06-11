using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Reflection;
using System.Xml;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("MatrixObject")]
    internal sealed class MatrixObject : TableBase
        {
        [UsedImplicitly][Field(Order=1000001,EmptyIfNull = true,Source="MatrixColumns")] public IList<MatrixHeaderDescriptor> Columns { get; }
        [UsedImplicitly][Field(Order=1000002,EmptyIfNull = true,Source="MatrixRows")]    public IList<MatrixHeaderDescriptor> Rows { get; }
        [UsedImplicitly][Field(Order=1000003,EmptyIfNull = true,Source="MatrixCells")]   public IList<MatrixCellDescriptor>   Cells { get; }
        [UsedImplicitly][Field(Order=1000601)][DefaultValue(true)] public Boolean AutoSize { get; } = true;
        [UsedImplicitly][Field(Order=1000602)] public Boolean CellsSideBySide { get; }
        [UsedImplicitly][Field(Order=1000603)] public Boolean KeepCellsSideBySide { get; }
        [UsedImplicitly][Field(Order=1000600)] public Int32 ColumnIndex { get; }
        [UsedImplicitly][Field(Order=1000600)] public Int32 RowIndex { get; }
        [UsedImplicitly][Field(Order=1000605)] public String Filter { get; }
        [UsedImplicitly][Field(Order=1000609)] public String ManualBuildEvent { get; }
        [UsedImplicitly][Field(Order=1000610)] public String ModifyResultEvent { get; }
        [UsedImplicitly][Field(Order=1000606)] public String ShowTitle { get; }
        [UsedImplicitly][Field(Order=1000604)] public String DataSource { get; }
        [UsedImplicitly][Field(Order=1000607)] public override String Style { get; }
        [UsedImplicitly][Field(Order=1000608)] public MatrixEvenStylePriority MatrixEvenStylePriority { get; }

        #region M:Serialize(XmlWriter,String,Object)
        public override void Serialize(XmlWriter writer,String prefix,Object other) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            var type = GetType();
            var className = type.GetCustomAttribute<FastReportClassAttribute>(false)?.Name ?? type.Name;
            using (writer.ElementGroup(className)) {
                SerializeAttributes(writer,prefix,(descriptor)=>
                    (descriptor.Name != "Columns") &&
                    (descriptor.Name != "Rows")    &&
                    (descriptor.Name != "Cells"));
                if (Columns.Any()) {
                    using (writer.ElementGroup("MatrixColumns")) {
                        foreach (var o in Columns) {
                            o.Serialize(writer,prefix,null);
                            }
                        }
                    }
                using (writer.ElementGroup("MatrixRows")) {
                    foreach (var o in Rows) {
                        o.Serialize(writer,prefix,null);
                        }
                    }
                if (Cells.Any()) {
                    using (writer.ElementGroup("MatrixCells")) {
                        foreach (var o in Cells) {
                            o.Serialize(writer,prefix,null);
                            }
                        }
                    }
                foreach (var o in Children) {
                    o.Serialize(writer,prefix,null);
                    }
                }
            }
        #endregion
        }
    }
