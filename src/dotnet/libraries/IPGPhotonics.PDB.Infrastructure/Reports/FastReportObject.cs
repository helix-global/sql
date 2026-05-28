using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Reflection;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    public class FastReportObject : SqlObject
        {
        #region M:Store(IDictionary<String,PropInfo>,IReadOnlyList<String>,String,Int32?)
        private static void Store(IDictionary<String,PropInfo> storage,IReadOnlyList<String> key,String value,Int32? lineNumber) {
            switch (key.Count) {
                case 1:
                    storage[key[0]] = new PropInfo(value) {
                        LineNumber = lineNumber
                        };
                    break;
                default:
                    {
                    if (!storage.TryGetValue(key[0],out var pi)) {
                        storage[key[0]] = pi = new PropInfo();
                        }
                    Store(pi.Children,key.Skip(1).ToArray(),value,lineNumber);
                    }
                    break;
                }
            }
        #endregion
        #region M:Apply(FastReportObject,IDictionary<String,PropInfo>)
        private static void Apply(FastReportObject source,IDictionary<String,PropInfo> storage) {
            ResolveFieldMappings(source.GetType(),out var mapping);
            foreach (var pi in storage) {
                if (!mapping.TryGetValue(pi.Key, out var mi)) {
                    throw new NotSupportedException(
                        (pi.Value.LineNumber != null)
                        ? $@"[Line={pi.Value.LineNumber}] @Attribute=""{pi.Key}"" with value ""{pi.Value}"" is not supported for ""{source.GetType().FullName}""."
                        : $@"@Attribute=""{pi.Key}"" with value ""{pi.Value}"" is not supported for ""{source.GetType().FullName}""."
                        );
                    }
                if (pi.Value.Value != null) { source.SetValue(mi,pi.Value.Value); }
                if (pi.Value.Children.Any()) {
                    var target = (FastReportObject)mi.GetValue(source);
                    Apply(target,pi.Value.Children);
                    }
                }
            }
        #endregion
        #region M:ReadXmlA(XmlReader)
        protected override void ReadXmlA(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            var storage = new Dictionary<String,PropInfo>();
            while (reader.MoveToNextAttribute()) {
                Store(storage,reader.LocalName.Split('.'),
                    reader.Value,(reader as IXmlLineInfo)?.LineNumber);
                }
            Apply(this,storage);
            }
        #endregion
        #region M:ReadXmlE(XmlReader)
        protected override void ReadXmlE(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            ResolveFieldMappings(GetType(),out var mapping);
            ForEachE(reader,(_)=>{
                    if (mapping.TryGetValue(reader.Name,out var pi)) {
                        if (IsGenericCollection(pi.PropertyType,out var TypeG,out var TypeE)){
                            var target = (IList)Activator.CreateInstance(typeof(List<>).MakeGenericType(TypeE));
                            using (var r = reader.ReadSubtree()) {
                                r.MoveToContent();
                                ForEachE(r,CreateE);
                                }
                            target = (IList)Activator.CreateInstance(typeof(ReadOnlyCollection<>).MakeGenericType(TypeE),target);
                            SetValue(pi,target);
                            return;
                            }
                        }
                    CreateE(reader);
                });
            }
        #endregion
        #region M:CreateE(XmlReader)
        protected virtual void CreateE(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            var o = CreateObject(reader.Name);
            if (o != null) {
                using (var r = reader.ReadSubtree()) {
                    o.ReadXml(r);
                    reader.Skip();
                    }
                return;
                }
            throw new NotSupportedException(
                (reader is IXmlLineInfo LineInfo)
                ? $@"[Line={LineInfo.LineNumber}] Element <{reader.Name}> is not supported for ""{GetType().FullName}""."
                : $@"<{reader.Name}> is not supported for ""{GetType().FullName}""."
                );
            }
        #endregion
        #region M:CreateObject(String):FastReportObject
        protected virtual FastReportObject CreateObject(String typeName) {
            if (RegisteredTypes.TryGetValue(typeName,out var type)) {
                return (FastReportObject)Activator.CreateInstance(type,nonPublic: true);
                }
            return null;
            }
        #endregion

        private class PropInfo
            {
            public String Value { get; }
            public Int32? LineNumber { get;set; }
            public IDictionary<String,PropInfo> Children { get; } = new Dictionary<String,PropInfo>();

            #region ctor
            public PropInfo()
                {
                Value = null;
                }
            #endregion
            #region ctor{String}
            public PropInfo(String value)
                {
                Value = value;
                }
            #endregion
            #region M:ToString:String
            /// <summary>Returns a string that represents the current object.</summary>
            /// <returns>A string that represents the current object.</returns>
            public override String ToString()
                {
                return Value;
                }
            #endregion
            }

        protected static readonly IDictionary<String,Type> RegisteredTypes = new ConcurrentDictionary<String,Type>();
        static FastReportObject() {
            foreach (var type in typeof(FastReportObject).Assembly.GetTypes()) {
                var attributes = type.GetCustomAttributes<FastReportClassAttribute>(inherit: false).ToArray();
                if (attributes.Length > 0) {
                    foreach (var attribute in attributes)
                        {
                        RegisteredTypes.Add(attribute.Name,type);
                        }
                    }
                }
            }
        }
    }
