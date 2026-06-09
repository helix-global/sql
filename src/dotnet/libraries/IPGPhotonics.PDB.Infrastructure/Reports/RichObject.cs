using System;
using System.Reflection;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("RichObject")]
    internal sealed class RichObject : TextObjectBase
        {
        [UsedImplicitly][Field(Order=1000601)] public Int32 ActualTextStart { get; }
        [UsedImplicitly][Field(Order=1000602)] public Int32 ActualTextLength { get; }
        [UsedImplicitly][Field(Order=1000603)] public String DataColumn { get; }
        [UsedImplicitly][Field(Order=1000604)] public Boolean OldBreakStyle { get; }

        #region M:Serialize(XmlWriter,String)
        public override void Serialize(XmlWriter writer,String prefix) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            var type = GetType();
            var className = type.GetCustomAttribute<FastReportClassAttribute>(false)?.Name ?? type.Name;
            var formats = Formats;
            using (writer.ElementGroup(className)) {
                SerializeAttributes(writer,prefix,(descriptor)=> {
                    if (descriptor.Name == nameof(Formats))    { return false; }
                    if (descriptor.Name == nameof(Format)) {
                        return (formats != null) && (formats.Count == 1);
                        }
                    return true;
                    });
                if ((formats != null) && (formats.Count > 1)) {
                    using (writer.ElementGroup("Formats")) {
                        foreach(var o in formats) {
                            o.SerializeFull(writer,prefix);
                            }
                        }
                    }
                foreach (var o in Children) {
                    o.Serialize(writer,prefix);
                    }
                }
            }
        #endregion
        }
    }
