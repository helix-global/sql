using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(XmlCompressionOption))]
    internal sealed class SqlFragmentXmlCompressionOption : SqlFragmentIndexOption<XmlCompressionOption>
        {
        #region ctor{IServiceProvider,XmlCompressionOption}
        public SqlFragmentXmlCompressionOption(IServiceProvider context,XmlCompressionOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }