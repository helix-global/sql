using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics.CodeAnalysis;
using System.Reflection;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("DataBand")]
    internal sealed class DataBand : BandBase
        {
        [UsedImplicitly][Field(Order=1000615)] public Boolean CollectChildRows { get; }
        [UsedImplicitly][Field(Order=1000611)] public Boolean KeepDetail { get; }
        [UsedImplicitly][Field(Order=1000610)] public Boolean KeepTogether { get; }
        [UsedImplicitly][Field(Order=1000609)] public Boolean PrintIfDatasourceEmpty { get; }
        [UsedImplicitly][Field(Order=1000608)] public Boolean PrintIfDetailEmpty { get; }
        [UsedImplicitly][Field(Order=1000616)] public Boolean ResetPageNumber { get; }
        [UsedImplicitly][Field(Order=1000601)] public String DataSource { get; }
        [UsedImplicitly][Field(Order=1000606)] public String Filter { get; }
        [UsedImplicitly][Field(Order=1000612)] public String IdColumn { get; }
        [UsedImplicitly][Field(Order=1000613)] public String ParentIdColumn { get; }
        [UsedImplicitly][Field(Order=1000604)] public String Relation { get; }
        [UsedImplicitly][Field(Order=1000602)][DefaultValue(1)] public Int32 RowCount { get; } = 1;
        [UsedImplicitly][Field(Order=1000603)] public Int32 MaxRows { get; }
        [UsedImplicitly][Field(Order=1000614,ConverterCulture="en-US")][DefaultValue(37.8f)] public Single Indent { get; } = 37.8f;
        [UsedImplicitly][Field(Order=1000607)] public BandColumns Columns { get; } = new BandColumns();
        [UsedImplicitly][Field("Sort")] public IList<Sort> Sorts { get; } = EmptyArray<Sort>.List;

        #region M:UpdateReferences(IList<FastReportObject>)
        [SuppressMessage("ReSharper", "LocalVariableHidesMember")]
        protected override void UpdateReferences(IList<FastReportObject> source) {
            base.UpdateReferences(source);
            //using (var Sorts = PrepareChanges(this.Sorts)) {
            //    foreach (var o in source) {
            //        if (o is Sort Sort) {
            //            Sorts.Add(Sort);
            //            }
            //        }
            //    }
            }
        #endregion
        #region M:Serialize(XmlWriter,String,Object)
        public override void Serialize(XmlWriter writer,String prefix,Object other) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            var type = GetType();
            var className = type.GetCustomAttribute<FastReportClassAttribute>(false)?.Name ?? type.Name;
            using (writer.ElementGroup(className)) {
                SerializeAttributes(writer,prefix,(descriptor)=>{
                    return !String.Equals(descriptor.Name,"Sorts");
                    });
                Serialize(writer,Children,prefix);
                if (Sorts.Count > 0) {
                    using (writer.ElementGroup("Sort")) {
                        Serialize(writer,Sorts,prefix);
                        }
                    }
                }
            }
        #endregion
        }
    }
