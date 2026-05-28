using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Reflection;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    public class FastReportObject : SqlObject
        {
        #region M:ResolveMappings(Object,{out}IDictionary<String,PropertyDescriptor>)
        private static void ResolveMappings(Object source,out IDictionary<String,PropertyDescriptor> mapping) {
            if (source is SqlObject) {
                ResolveFieldMappings(source.GetType(),out mapping);
                }
            else
                {
                mapping = TypeDescriptor.GetProperties(source).
                    OfType<PropertyDescriptor>().
                    Select(i=>(PropertyDescriptor)new PropDesc(i)).
                    ToDictionary(i=>i.Name,i=>i);
                }
            }
        #endregion
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
        private static void Apply(Object source,IDictionary<String,PropInfo> storage) {
            ResolveMappings(source,out var mapping);
            foreach (var pi in storage) {
                if (!mapping.TryGetValue(pi.Key, out var mi)) {
                    throw new NotSupportedException(
                        (pi.Value.LineNumber != null)
                        ? $@"[Line={pi.Value.LineNumber}] @Attribute=""{pi.Key}"" with value ""{pi.Value}"" is not supported for ""{source.GetType().FullName}""."
                        : $@"@Attribute=""{pi.Key}"" with value ""{pi.Value}"" is not supported for ""{source.GetType().FullName}""."
                        );
                    }
                if (pi.Value.Value != null) {
                    if (source is FastReportObject o)
                        {
                        o.SetValue(mi,pi.Value.Value);
                        }
                    else
                        {
                        mi.SetValue(source,pi.Value.Value);
                        }
                    }
                if (pi.Value.Children.Any()) {
                    var target = mi.GetValue(source);
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

        private class PropDesc : PropertyDescriptor
            {
            #region ctor{String,Attribute[]}
            public PropDesc([NotNull] String name,Attribute[] attrs)
                : base(name,attrs)
                {
                }
            #endregion
            #region ctor{PropertyDescriptor}
            public PropDesc([NotNull] PropertyDescriptor descr)
                : base(descr)
                {
                this.descr = descr;
                }
            #endregion
            #region ctor{MemberDescriptor,Attribute[]}
            public PropDesc([NotNull] MemberDescriptor descr,Attribute[] attrs)
                : base(descr,attrs)
                {
                }
            #endregion

            #region M:CanResetValue(Object):Boolean
            public override Boolean CanResetValue(Object component)
                {
                return descr.CanResetValue(component);
                }
            #endregion
            #region M:GetValue(Object):Object
            public override Object GetValue(Object component)
                {
                return descr.GetValue(component);
                }
            #endregion
            #region M:ResetValue(Object)
            public override void ResetValue(Object component)
                {
                descr.ResetValue(component);
                }
            #endregion
            #region M:SetValue(Object,Object)
            /// <summary>Sets the value of the component to a different value.</summary>
            /// <param name="component">The component with the property value that is to be set.</param>
            /// <param name="value">The new value.</param>
            public override void SetValue(Object component,Object value) {
                if (value != null) {
                    var converter = Converter;
                    if (converter != null) {
                        if (converter.CanConvertFrom(value.GetType())) {
                            value = converter.ConvertFrom(value);
                            }
                        }
                    }
                descr.SetValue(component,value);
                }
            #endregion
            #region M:ShouldSerializeValue(Object):Boolean
            public override Boolean ShouldSerializeValue(Object component)
                {
                return descr.ShouldSerializeValue(component);
                }
            #endregion

            public override Type ComponentType { get { return descr.ComponentType; }}
            public override Boolean IsReadOnly { get { return descr.IsReadOnly;    }}
            public override Type PropertyType  { get { return descr.PropertyType;  }}

            private readonly PropertyDescriptor descr;
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
