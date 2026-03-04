using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptForXmlRawClause : SqlScriptForXmlClause<SqlForXmlRawClause>
        {
        public String ElementName {get{ return Source.ElementName; }}

        #region ctor{IServiceProvider,SqlForXmlRawClause}
        public SqlScriptForXmlRawClause(IServiceProvider context,SqlForXmlRawClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }