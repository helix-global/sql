using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(XmlCompressionOption))]
    internal sealed class SqlScriptDomXmlCompressionOption : SqlScriptDomIndexOption<XmlCompressionOption>
        {
        #region ctor{IServiceProvider,XmlCompressionOption}
        public SqlScriptDomXmlCompressionOption(IServiceProvider context,XmlCompressionOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }