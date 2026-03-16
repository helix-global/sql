using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlInlineTableVariableDeclaration))]
    internal sealed class SqlScriptInlineTableVariableDeclaration : SqlScriptCodeObject<SqlInlineTableVariableDeclaration>
        {
        #region ctor{IServiceProvider,SqlInlineTableVariableDeclaration}
        public SqlScriptInlineTableVariableDeclaration(IServiceProvider context,SqlInlineTableVariableDeclaration source)
            : base(context,source)
            {
            }
        #endregion
        }
    }