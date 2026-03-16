using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDropSchemaStatement))]
    internal sealed class SqlScriptDropSchemaStatement : SqlScriptDropStatement<SqlDropSchemaStatement>
        {
        #region ctor{IServiceProvider,SqlDropSchemaStatement}
        public SqlScriptDropSchemaStatement(IServiceProvider context,SqlDropSchemaStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }