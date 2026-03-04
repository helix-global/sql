using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    public class DataSchemaModel : DataSchemaModelElement
        {
        public DataSchemaModelDatabaseOptions DatabaseOptions { get;private set; }
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] protected override DataSchemaModel Scope { get{ return null; }}
        #region ctor
        private DataSchemaModel()
            : base(null)
            {
            }
        #endregion

        #region M:LoadFrom(String):DataSchemaModel
        public static DataSchemaModel LoadFrom(String filename) {
            using (var reader = XmlReader.Create(filename)) {
                return LoadFrom(reader);
                }
            }
        #endregion
        #region M:LoadFrom(XmlReader):DataSchemaModel
        public static DataSchemaModel LoadFrom(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            var r = new DataSchemaModel();
            r.ReadXml(reader);
            r.UpdateRelationships();
            return r;
            }
        #endregion
        #region M:ReadXml(XmlReader)
        /// <summary>Generates an object from its XML representation.</summary>
        /// <param name="reader">The <see cref="T:System.Xml.XmlReader"/> stream from which the object is deserialized.</param>
        protected internal override void ReadXml(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            reader.MoveToContent();
            if (reader.NamespaceURI != URI_DAC) { throw new NotSupportedException(); }
            switch (reader.LocalName) {
                #region DataSchemaModel
                case "DataSchemaModel":
                    while (reader.Read()) {
                        switch (reader.NodeType) {
                            case XmlNodeType.Element:
                                {
                                switch (reader.Name) {
                                    case "Model":
                                        {
                                        using (var r = reader.ReadSubtree()) {
                                            ReadXml(r);
                                            reader.Skip();
                                            }
                                        }
                                        return;
                                    default: throw new InvalidDataException();
                                    }
                                }
                            }
                        }
                    break;
                #endregion
                #region Model
                case "Model":
                    while (reader.Read()) {
                        switch (reader.NodeType) {
                            case XmlNodeType.Element:
                                {
                                switch (reader.Name) {
                                    case "Element":
                                        {
                                        var Type = reader.GetAttribute("Type");
                                        using (var r = reader.ReadSubtree()) {
                                            //var o = Ignore;
                                            DataSchemaModelElement o = null;
                                            if (RegisteredTypes.TryGetValue(Type, out var type)) {
                                                var ctor = type.GetConstructor(BindingFlags.Instance|BindingFlags.Public|BindingFlags.NonPublic,null,CallingConventions.Any,new []{typeof(DataSchemaModel) },null);
                                                o = (DataSchemaModelElement)ctor.Invoke(new Object[]{this });
                                                }
                                            if (o == null) {
                                                throw new NotSupportedException($@"Element ""{Type}"" not supported.");
                                                }
                                            if (!o.IsIgnore)
                                                {
                                                o.LineNumber = (reader as IXmlLineInfo)?.LineNumber;
                                                o.ReadXml(r);
                                                Elements.Add(o);
                                                }
                                            reader.Skip();
                                            }
                                        }
                                        break;
                                    default: throw new InvalidDataException();
                                    }
                                }
                                break;
                            }
                        }
                    break;
                #endregion
                default: throw new NotSupportedException($@"Element ""{reader.LocalName}"" not supported.");
                }
            }
        #endregion
        #region M:UpdateRelationships
        protected override void UpdateRelationships()
            {
            base.UpdateRelationships();
            DatabaseOptions = Elements.OfType<DataSchemaModelDatabaseOptions>().FirstOrDefault();
            }
        #endregion
        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Name??"DataSchemaModel";
            }
        #endregion
        }
    }
