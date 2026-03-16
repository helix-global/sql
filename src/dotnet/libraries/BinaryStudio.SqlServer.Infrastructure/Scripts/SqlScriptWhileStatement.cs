using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlWhileStatement))]
    internal class SqlScriptWhileStatement : SqlScriptConditionalStatement<SqlWhileStatement>
        {
        #region ctor{IServiceProvider,SqlWhileStatement}
        public SqlScriptWhileStatement(IServiceProvider context,SqlWhileStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }