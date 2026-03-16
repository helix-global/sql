using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDropUserStatement))]
    internal sealed class SqlScriptDropUserStatement : SqlScriptDropStatement<SqlDropUserStatement>
        {
        #region ctor{IServiceProvider,SqlDropUserStatement}
        public SqlScriptDropUserStatement(IServiceProvider context,SqlDropUserStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }