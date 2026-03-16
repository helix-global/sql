using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlForXmlAutoClause))]
    internal sealed class SqlScriptForXmlAutoClause : SqlScriptForXmlClause<SqlForXmlAutoClause>
        {
        #region ctor{IServiceProvider,SqlForXmlAutoClause}
        public SqlScriptForXmlAutoClause(IServiceProvider context,SqlForXmlAutoClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }