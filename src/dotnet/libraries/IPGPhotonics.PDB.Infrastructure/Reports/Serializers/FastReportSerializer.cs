using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal class FastReportSerializer : FastReportVisitor
        {
        #region ctor{XmlWriter}
        public FastReportSerializer(XmlWriter writer)
            {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            m_writer = writer;
            }
        #endregion

        #region Visit(FastReport)
        public override void Visit(FastReport o) {
            if (o == null) { throw new ArgumentNullException(nameof(o)); }
            using (m_writer.ElementGroup("A2Report")) {
                WriteProperties(m_writer,o);
                if (!String.IsNullOrWhiteSpace(o.Script)) {
                    using (m_writer.ElementGroup("ScriptText")) {
                        m_writer.WriteRaw(EncodeString(o.Script));
                        }
                    }
                if (o.DataSources.Any()) {
                    using (m_writer.ElementGroup("Dictionary")) {
                        Visit(o.DataSources);
                        }
                    }
                }
            base.Visit(o);
            }
        #endregion
        #region M:Visit(DataConnectionBase)
        public override void Visit(DataConnectionBase o) {
            var type = o.GetType();
            var className = type.GetCustomAttribute<FastReportClassAttribute>()?.Name ?? type.Name;
            using (m_writer.ElementGroup(className)) {
                WriteProperties(m_writer,o,(descriptor)=>{
                    switch (descriptor.Name) {
                        case nameof(DataConnectionBase.Tables): return false;
                        default: return true;
                        }
                    });
                base.Visit(o);
                }
            }
        #endregion
        #region M:Visit(TableDataSource)
        public override void Visit(TableDataSource o) {
            var type = o.GetType();
            var className = type.GetCustomAttribute<FastReportClassAttribute>(false)?.Name ?? type.Name;
            using (m_writer.ElementGroup(className)) {
                WriteProperties(m_writer,o);
                base.Visit(o);
                }
            }
        #endregion
        #region M:Visit(Column)
        public override void Visit(Column o) {
            var type = o.GetType();
            var className = type.GetCustomAttribute<FastReportClassAttribute>(false)?.Name ?? type.Name;
            using (m_writer.ElementGroup(className)) {
                WriteProperties(m_writer,o);
                base.Visit(o);
                }
            }
        #endregion
        #region M:Visit(CommandParameter)
        public override void Visit(CommandParameter o) {
            var type = o.GetType();
            var className = type.GetCustomAttribute<FastReportClassAttribute>(false)?.Name ?? type.Name;
            using (m_writer.ElementGroup(className)) {
                WriteProperties(m_writer,o);
                base.Visit(o);
                }
            }
        #endregion
        #region M:Order(PropertyDescriptor):Int32
        private static Int32 Order(PropertyDescriptor descriptor) {
            var r = descriptor.Attributes.OfType<SqlObjectFieldMappingAttribute>().FirstOrDefault();
            return (r != null)
                ? r.Order
                : 0;
            }
        #endregion
        #region M:EncodeString(String):String
        private static String EncodeString(String value) {
            if (String.IsNullOrEmpty(value)) { return value; }
            return value.
                Replace("<","&lt;").
                Replace(">","&gt;").
                Replace("\"","&quot;").
                Replace("'","&apos;");
            }
        #endregion
        #region M:WriteProperties<T>(XmlWriter,T)
        private static void WriteProperties<T>(XmlWriter writer,T o) {
            WriteProperties(writer,o,predicate: null);
            }
        #endregion
        #region M:WriteProperties<T>(XmlWriter,T,Func<PropertyDescriptor,Boolean>)
        private static void WriteProperties<T>(XmlWriter writer,T o,Func<PropertyDescriptor,Boolean> predicate) {
            foreach (var descriptor in TypeDescriptor.GetProperties(o).Cast<PropertyDescriptor>().Select(i=>new PropertyLink(i)).OrderBy(Order)) {
                if ((predicate == null) || predicate(descriptor)) {
                    var value = descriptor.GetValue(o);
                    var defaultValue = descriptor.Attributes.OfType<DefaultValueAttribute>().FirstOrDefault();
                    if (defaultValue != null && Equals(value,defaultValue.Value)) { continue; }
                    if (value == null) { continue; }
                    var field = descriptor.Attributes.OfType<SqlObjectFieldMappingAttribute>().FirstOrDefault();
                    if (field != null) {
                        var name = field.Source ?? descriptor.Name;
                        var converter = descriptor.Converter;
                        if (field.Converter != null) {
                            converter = (TypeConverter)Activator.CreateInstance(field.Converter);
                            }
                        writer.WriteAttributeString(name,converter.ConvertToInvariantString(value));
                        }
                    }
                }
            }
        #endregion

        private class PropertyLink: PropertyDescriptor
            {
            #region ctor{PropertyDescriptor}
            public PropertyLink(PropertyDescriptor source)
                :base(source)
                {
                m_source = source;
                }
            #endregion

            public override Type ComponentType => m_source.ComponentType;
            public override Boolean IsReadOnly => m_source.IsReadOnly;
            public override Type PropertyType  => m_source.PropertyType;

            #region P:Converter:TypeConverter
            public override TypeConverter Converter { get {
                if (PropertyType == typeof(Boolean)) { return new FastReportBooleanConverter(); }
                return base.Converter;
                }}
            #endregion

            #region M:CanResetValue(Object):Boolean
            public override Boolean CanResetValue(Object component)
                {
                return m_source.CanResetValue(component);
                }
            #endregion
            #region M:GetValue(Object):Object
            public override Object GetValue(Object component)
                {
                return m_source.GetValue(component);
                }
            #endregion
            #region M:ResetValue(Object)
            public override void ResetValue(Object component)
                {
                m_source.ResetValue(component);
                }
            #endregion
            #region M:SetValue(Object,Object):String
            public override void SetValue(Object component,Object value)
                {
                m_source.SetValue(component,value);
                }
            #endregion
            #region M:ShouldSerializeValue(Object):Boolean
            public override Boolean ShouldSerializeValue(Object component)
                {
                return m_source.ShouldSerializeValue(component);
                }
            #endregion

            private readonly PropertyDescriptor m_source;
            }

        private readonly XmlWriter m_writer;
        }
    }
