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
        #region M:ReadXmlA(XmlReader)
        protected override void ReadXmlA(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            var properties = new Dictionary<String,PropInfo>();
            while (reader.MoveToNextAttribute()) {
                var local = reader.LocalName;
                var index = local.IndexOf('.');
                if (index == -1) {
                    properties[local] = new PropInfo(reader.Value)
                        {
                        LineNumber = (reader as IXmlLineInfo)?.LineNumber
                        };
                    }
                else
                    {
                    var global = local.Substring(0,index);
                    local = local.Substring(index+1);
                    if (!properties.TryGetValue(global,out var pi)) {
                        properties[global] = pi = new PropInfo();
                        }
                    pi.Children[local] = new PropInfo(reader.Value)
                        {
                        LineNumber = (reader as IXmlLineInfo)?.LineNumber
                        };
                    }
                }

            ResolveFieldMappings(GetType(),out var mapping);
            foreach (var pi in properties.Where(i => !i.Value.Children.Any())) {
                if (!mapping.TryGetValue(pi.Key, out var mi)) {
                    throw new NotSupportedException(
                        (pi.Value.LineNumber != null)
                        ? $@"[Line={pi.Value.LineNumber}] @Attribute=""{pi.Key}"" with value ""{pi.Value}"" is not supported for ""{GetType().FullName}""."
                        : $@"@Attribute=""{pi.Key}"" with value ""{pi.Value}"" is not supported for ""{GetType().FullName}""."
                        );
                    }
                SetValue(mi,pi.Value.Value);
                }
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
            if (RegisteredTypes.TryGetValue(reader.Name, out var type)) {
                using (var r = reader.ReadSubtree()) {
                    var o = (FastReportObject)Activator.CreateInstance(type,nonPublic: true);
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
