using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlForXmlPathClause))]
    internal sealed class SqlScriptForXmlPathClause : SqlScriptForXmlClause<SqlForXmlPathClause>
        {
        #region ctor{IServiceProvider,SqlForXmlPathClause}
        public SqlScriptForXmlPathClause(IServiceProvider context,SqlForXmlPathClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }