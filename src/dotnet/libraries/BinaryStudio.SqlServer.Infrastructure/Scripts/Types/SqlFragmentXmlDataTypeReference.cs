using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(XmlDataTypeReference))]
    internal sealed class SqlFragmentXmlDataTypeReference : SqlFragmentDataTypeReference<XmlDataTypeReference>
        {
        #region ctor{IServiceProvider,XmlDataTypeReference}
        public SqlFragmentXmlDataTypeReference(IServiceProvider context,XmlDataTypeReference source)
            : base(context,source)
            {
            }
        #endregion
        }
    }