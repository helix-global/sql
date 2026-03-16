using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlCreateSchemaStatement))]
    internal sealed class SqlScriptCreateSchemaStatement : SqlScriptDdlStatement<SqlCreateSchemaStatement>
        {
        #region ctor{IServiceProvider,SqlCreateSchemaStatement}
        public SqlScriptCreateSchemaStatement(IServiceProvider context,SqlCreateSchemaStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }