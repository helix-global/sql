using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlForXmlExplicitClause))]
    internal sealed class SqlScriptForXmlExplicitClause : SqlScriptForXmlClause<SqlForXmlExplicitClause>
        {
        #region ctor{IServiceProvider,SqlForXmlExplicitClause}
        public SqlScriptForXmlExplicitClause(IServiceProvider context,SqlForXmlExplicitClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }